require 'rake'

# https://github.com/mattmassicotte/rake-multifile
module RakeMultifile
  class MultiFileTask < Rake::FileTask
    private
    def invoke_prerequisites(task_args, invocation_chain)
      invoke_prerequisites_concurrently(task_args, invocation_chain)
    end
  end
end

def multifile(*args, &block)
  RakeMultifile::MultiFileTask.define_task(*args, &block)
end
