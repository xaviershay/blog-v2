require 'digest/md5'
require 'json'

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

class FileSource
  def current_hash
    @current_hash ||= Digest::MD5.hexdigest(File.read(@target)) rescue nil
  end

  def saved_hash
    $hashes[@target]
  end

  attr_reader :target, :changed
end

class SourceFile < FileSource
  def initialize(target)
    @target = target
  end

  def run_if_needed
    return if @changed

    if current_hash != saved_hash
      puts "Source file changed: #{@target}"
      @changed = true
    end
  end
end

class GeneratedFile < FileSource
  def initialize(target, deps, &block)
    @target = target
    @deps = deps
    @block = block
    @run = false
    @changed = false
  end

  def run_if_needed
    return if @run

    @deps.each do |dep|
      dep.run_if_needed
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

$tasks = {}

def add_task(task)
  $tasks[task.target] = task
end

def lookup_tasks(tasks)
  tasks.map {|x| $tasks[x] }
end

add_task SourceFile.new("test/source1.txt")
task = GeneratedFile.new(
  "test/generated1.txt",
  lookup_tasks(%w(test/source1.txt))
) { `cat test/source1.txt | wc -c > test/generated1.txt` }
add_task task

task = GeneratedFile.new(
  "test/generated2.txt",
  lookup_tasks(%w(test/source1.txt))
) { `cat test/source1.txt | wc -l > test/generated2.txt` }
add_task task

$hashes =
  begin
    JSON.parse(File.read("hashes"))
  rescue
    {}
  end

$tasks['test/generated1.txt'].run_if_needed
$tasks['test/generated2.txt'].run_if_needed

$tasks.values.each do |t|
  #puts "#{t.current_hash} #{t.target}"
  $hashes[t.target] = t.current_hash
end

File.write("hashes", JSON.pretty_generate($hashes))
