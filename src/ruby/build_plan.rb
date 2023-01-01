class BuildPlan
  module Target
    class Base
      attr_reader :target, :deps
      attr_accessor :dep_changed

      def initialize(target, deps)
        @target = target
        @deps = deps
        @dep_changed = false
      end

      # TODO
      def changed?(digests)
        false
      end
    end

    class IntermediaryFile < Base
      def initialize(target, deps, &block)
        super(target, deps)
        @block = block
      end

      def id
        target
      end

      def run(digests)
        old_digest = current_digest
        @block.call
        new_digest = Digest::MD5.hexdigest(File.read(@target)) rescue nil
        old_digest != new_digest
      end

      def current_digest
        if !defined?(@current_digest)
          @current_digest = Digest::MD5.hexdigest(File.read(target)) rescue nil
        end
        @current_digest
      end

      def changed?(digests)
        !current_digest || current_digest != digests[target]
      end
    end

    class SourceFile < Base
      attr_reader :target

      def initialize(target)
        super(target, [])
      end

      def id
        target
      end

      def run(digests)
        if current_digest.nil?
          raise "source file does not exist: #{target}"
        else
          current_digest != digests[target]
        end
      end

      def current_digest
        if !defined?(@current_digest)
          @current_digest = Digest::MD5.hexdigest(File.read(target)) rescue nil
        end
        @current_digest
      end
    end
  end

  def self.logger
    @logger ||= Logger.new(STDOUT)
  end

  def self.logger=(logger)
    @logger = logger
  end

  def initialize
    @digests = {}
    @tasks = {}
  end

  def register_file(path, digest)
    digests[path] = digest
  end

  def load(&block)
    instance_exec(&block)
  end

  def logger
    self.class.logger
  end

  def build(*targets)
    forward = Hash.new {|h, k| h[k] = Set.new }
    backward = Hash.new {|h, k| h[k] = Set.new }

    walk = ->(target, parent) do
      task = tasks.fetch(target)
      forward[target] ||= Set.new
      task.deps.each do |dep|
        walk.(dep, task)
        forward[target] << dep
      end

      backward[target] << parent.target if parent
    end

    targets.each do |target|
      walk.(target, nil)
    end

    seeds = forward.select {|k, v| v.empty? }.keys

    # TODO: Build loop
    while seeds.any?
      logger.debug ""
      logger.debug "Available: #{seeds}"
      seed = seeds.shift
      logger.debug "Running #{seed}"
      t = tasks[seed]

      notify = backward[seed]

      logger.debug "Rebuilding #{seed}"
      changed = t.run(digests)
      logger.debug "#{seed} changed: #{changed}. notifying parents: #{notify}"
      notify.each do |parent, _|
        parent_task = tasks[parent]
        parent_task.dep_changed ||= changed
        x = forward[parent]
        x.delete(seed)
        logger.debug "  Dependencies remaining: #{x.inspect}"
        if x.empty? && (parent_task.dep_changed || parent_task.changed?(digests))
          seeds << parent
        end
      end
      backward.delete(seed)
    end
  end

  def file(opts, &block)
    opts.each do |target, deps|
      deps = [*deps]
      deps.each do |dep|
        # Generate default source file targets if target hasn't been defined
        # yet.  Defining it explicitly later on will override this default.
        task = Target::SourceFile.new(dep)
        tasks[task.id] ||= task
      end
      task = Target::IntermediaryFile.new(target, deps, &block)
      tasks[task.id] = task
    end
  end

  attr_reader :digests, :tasks
end
