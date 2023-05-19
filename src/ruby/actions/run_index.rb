require 'support/builder'

class Actions::RunIndex < Builder
  def compile_erb(layout, template, metadata_file, output)
    metadata = {} # load_book_index_metadata(metadata_file)

    @site = hash_to_ostruct(metadata)
    @site.extend(RunSiteMethods)

    @site.yearly_stats = {
      2021 => hash_to_ostruct(distance: 2508.0, elevation: 39659),
      2022 => hash_to_ostruct(distance: 2056.0, elevation: 31403),
      2023 => hash_to_ostruct(distance: 1256.0, elevation: 32613)
    }
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
