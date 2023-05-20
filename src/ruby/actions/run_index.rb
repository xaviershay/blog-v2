require 'support/builder'

class Actions::RunIndex < Builder
  def compile_erb(layout, template, metadata_file, output)
    metadata = YAML.load_file(metadata_file)

    @site = hash_to_ostruct(metadata)
    @site.extend(RunSiteMethods)

    @content = load_template(template).result(binding)
    @metadata_title = "Running — Xavier Shay"
    @title = "Running"
    @subtitle = ""
    @class = "run-index"

    html = load_template(layout).result(binding)
    write_gzip output, html
  end

  module RunSiteMethods
  end
end
