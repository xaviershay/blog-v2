require 'digest'
require 'fileutils'
require 'shellwords'
require 'tmpdir'

# Compiles TikZ source to SVG, caching by SHA1 hash of the source.
# SVGs are stored in data/images/tikz/ and served from /images/tikz/.
module TikzCompiler
  SVG_DIR = "data/images/tikz"

  LATEX_TEMPLATE = <<~'LATEX'
    \documentclass{standalone}
    \usepackage{xcolor}
    \usepackage{tikz}
    \begin{document}
    \nopagecolor
    %s
    \end{document}
  LATEX

  # Returns the web-root-relative image path, compiling the SVG if not cached.
  def self.svg_url(tikz_code)
    hash = Digest::SHA1.hexdigest(tikz_code)
    svg_filename = "#{hash}.svg"
    svg_path = "#{SVG_DIR}/#{svg_filename}"

    unless File.exist?(svg_path)
      FileUtils.mkdir_p(SVG_DIR)
      compile(tikz_code, svg_path)
    end

    "/images/tikz/#{svg_filename}"
  end

  def self.compile(tikz_code, output_path)
    latex = LATEX_TEMPLATE % tikz_code

    Dir.mktmpdir("tikz") do |tmpdir|
      tex_file = File.join(tmpdir, "tikz.tex")
      pdf_file = File.join(tmpdir, "tikz.pdf")

      File.write(tex_file, latex)

      pdf_output = `pdflatex -interaction=nonstopmode -output-directory #{Shellwords.escape(tmpdir)} #{Shellwords.escape(tex_file)} 2>&1`
      unless File.exist?(pdf_file)
        raise "pdflatex failed compiling #{output_path}:\n#{pdf_output}"
      end

      svg_output = `pdf2svg #{Shellwords.escape(pdf_file)} #{Shellwords.escape(output_path)} 2>&1`
      unless File.exist?(output_path)
        raise "pdf2svg failed for #{output_path}:\n#{svg_output}"
      end
    end
  end
end
