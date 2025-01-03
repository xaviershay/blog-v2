require 'support/builder'

class Actions::RunIndex < Builder
  def compile_erb(layout, template, metadata_file, output)
    metadata = YAML.load_file(metadata_file, permitted_classes: [Date])

    @site = hash_to_ostruct(metadata)
    @site.extend(RunSiteMethods)

    @content = load_template(template).result(binding)
    @metadata_title = "Running — Xavier Shay"
    @title = "Running"
    @subtitle = ""
    @class = "run-index"

    html = load_template(layout).result(binding)
    write_gzip output, html
  rescue Psych::BadAlias
    puts File.read(metadata_file)

    raise "Failed to YAML parse #{metadata_file}"
  end

  def format_thousands(x)
    parts = x.to_s.split('.')
    parts[0].gsub!(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1,")
    parts.join('.')
  end

  def format_duration(x)
    if x < 3600
      "%i:%02i" % [x / 60, x % 60]
    else
      "%i:%02i:%02i" % [x / 3600, (x % 3600) / 60, x % 60]
    end
  end

  module RunSiteMethods
  end
end
