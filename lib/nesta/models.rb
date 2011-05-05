module Nesta
  class FileModel
    def parse_file
      contents = File.open(@filename).read
    rescue Errno::ENOENT
      raise Sinatra::NotFound
    else
      first_paragraph, remaining = contents.split(/\r?\n\r?\n/, 2)
      metadata = {}
      if metadata?(first_paragraph)
        data = YAML.load(first_paragraph)
        if data.is_a?(Hash)
          data.each do |key, value|
            metadata[key.downcase] = value
          end
        end
      end
      markup = metadata?(first_paragraph) ? remaining : contents
      return metadata, markup
    end

    def convert_to_html(format, scope, text)
      case format
      when :mdown
        ::Nesta::Markdown.new(text).to_html
      when :haml
        Haml::Engine.new(text).to_html(scope)
      when :textile
        RedCloth.new(text).to_html
      end
    end
  end

  class Page < FileModel
    def summary
      if summary_text = metadata("summary")
        summary_text.gsub!('\n', "\n")
        case @format
        when :textile
          RedCloth.new(summary_text).to_html
        else
          ::Nesta::Markdown.new(summary_text).to_html
        end
      end
    end

    def heading
      if metadata('heading')
        metadata('heading')
      else
        regex = case @format
                when :mdown
                  /^#\s*(.*?)(\s*#+|$)/
                when :haml
                  /^\s*%h1\s+(.*)/
                when :textile
                  /^\s*h1\.\s+(.*)/
                end
        markup =~ regex
        Regexp.last_match(1)
      end
    end

    def title
      if metadata('title')
        metadata('title')
      elsif heading
        "#{heading} - #{Nesta::Config.title}"
      elsif abspath == '/'
        Nesta::Config.title
      end
    end
  end
end
