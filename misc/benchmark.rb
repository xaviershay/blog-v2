require 'digest/md5'
require 'json'
require 'pp'
require 'set'

Dir['data/books/*.md'].each do |f|
  File.mtime(f)
  Digest::MD5.hexdigest(File.read(f))
end

Dir['out/html/**/*.html'].each do |f|
  File.mtime(f)
  Digest::MD5.hexdigest(File.read(f))
end

# 70ms - start up time, 20ms with --disable=gems
# +0ms - mtime everything
# +30ms - MD5 hash all source files
#
# 42m for everything

# GIVEN:
# - A list of source files
# - The MD5 hash of each file used to generate current version (or nil if new), and mtime (don't recompare if mtime hasn't changed)
# - The current version of a file
# - A task to be executed to generate a new version file
#
# Re-run task if any MD5 have changed.

$hashes = {}

class Task
  attr_reader :target
  attr_accessor :dep_changed

  def initialize(target, deps)
    @target = target
    @deps = deps
    @dep_changed = false
  end

  def walk(forward, backward, parent)
    forward[target] ||= Set.new

    @deps.each do |dep|
      dep.walk(forward, backward, self)
      forward[target] << dep.target
    end

    backward[target] ||= Set.new
    backward[target] << parent.target if parent
  end
end

class DirectoryTask < Task
  def initialize(target)
    @target = target
    @deps = []
  end

  def run
    return false if Dir.exists?(target)

    FileUtils.mkdir_p(target)
    true
  end

  def current_hash
    nil
  end
end

class FileSource < Task
  def current_hash
    @current_hash ||= Digest::MD5.hexdigest(File.read(@target)) rescue nil
  end

  def saved_hash
    $hashes[@target]
  end

  attr_reader :changed
end

$runnable = {}

class SourceFile < FileSource
  def initialize(target)
    @target = target
    @deps = []
  end
  
  def run_if_needed
    return if @changed

    if current_hash != saved_hash
      puts "Source file changed: #{@target}"
      @changed = true
    end
  end

  def run
    current_hash != saved_hash
  end
end

class FileExistsTask < Task
  def initialize(target)
    @target = target
    @deps = []
  end

  def run
    !File.exists?(@target.split(":")[1])
  end

  def current_hash
    nil
  end
end

class GeneratedFile < FileSource
  def initialize(target, deps, &block)
    super target, deps
    @block = block
    @run = false
    @changed = false
  end

  def run
    puts "Rebuilding #{target}"
    old_hash = current_hash
    @block.call
    new_hash = Digest::MD5.hexdigest(File.read(@target)) rescue nil
    old_hash != new_hash
  end

  def run_if_needed(notify)
    return if @run

    @deps.each do |dep|
      dep.run_if_needed(self)
      @run = true if dep.changed
    end

    if @run || !File.exists?(@target)
      puts "Running #{target}"
      @block.call
      @current_hash = nil
      new_hash = Digest::MD5.hexdigest(File.read(@target)) rescue nil
      @changed = new_hash != current_hash
    end
  end
end

class SyntheticTask < Task
  attr_reader :target

  def run
    true
  end

  def current_hash
    nil
  end
end

$tasks = {}

def add_task(task)
  $tasks[task.target] = task
end

def lookup_tasks(tasks)
  tasks.map {|x| $tasks[x] }
end

add_task SourceFile.new("test/source1.txt")
add_task DirectoryTask.new("test")

add_task FileExistsTask.new('exists:test/generated1.txt')
task = GeneratedFile.new(
  "test/generated1.txt",
  lookup_tasks(%w(test test/source1.txt exists:test/generated1.txt))
) { `cat test/source1.txt | wc -c > test/generated1.txt` }
add_task task

add_task FileExistsTask.new('exists:test/generated2.txt')
task = GeneratedFile.new(
  "test/generated2.txt",
  lookup_tasks(%w(test test/source1.txt exists:test/generated2.txt))
) { `cat test/source1.txt | wc -l > test/generated2.txt` }
add_task task

add_task SyntheticTask.new("build", lookup_tasks(%w(test/generated1.txt test/generated2.txt)))

$hashes =
  begin
    JSON.parse(File.read("hashes"))
  rescue
    {}
  end

# $tasks['test/generated1.txt'].run_if_needed
# $tasks['test/generated2.txt'].run_if_needed

t = $tasks['build']
#t = $tasks['test/generated1.txt']
forward = {}
backward = {}
t.walk(forward, backward, nil)
pp forward
pp backward

seeds = forward.select {|k, v| v.empty? }.keys

# TODO: How to force build when file does not exist?

puts
puts "====="
puts

while seeds.any?
  puts "Available: #{seeds}"
  seed = seeds.shift
  puts
  puts "Running #{seed}"
  t = $tasks[seed]

  notify = backward[seed]
  changed = t.run
  puts "#{seed} changed: #{changed}. notifying parents: #{notify}"
  notify.each do |parent, _|
    parent_task = $tasks[parent]
    parent_task.dep_changed ||= changed
    x = forward[parent]
    x.delete(seed)
    puts "  Dependencies remaining: #{x.inspect}"
    if x.empty? && parent_task.dep_changed
      seeds << parent
    end
  end
  backward.delete(seed)
end

$tasks.values.each do |t|
  #puts "#{t.current_hash} #{t.target}"
  $hashes[t.target] = t.current_hash
end

File.write("hashes", JSON.pretty_generate($hashes))
