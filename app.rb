module Nesta
  class Page < FileModel
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

  class App < Sinatra::Base
    register Padrino::Helpers

    def cache(content, opts = {})
      # Cache for a month
      cache_for = opts[:for] || 2592000 

      if options.cache_enabled && !content.nil?
        response.headers['Cache-Control'] = "public, max-age=#{cache_for}"
        log("Cached Page: [#{request.path_info}]",:info) 
      end

      content
    end
    
    helpers do
      def partial(template, *args)
        template_array = template.to_s.split('/')
        template = template_array[0..-2].join('/') + "/_#{template_array[-1]}"
        options = args.last.is_a?(Hash) ? args.pop : {}
        options.merge!(:layout => false)
        if collection = options.delete(:collection) then
          collection.inject([]) do |buffer, member|
            buffer << erb(:"#{template}", options.merge(:layout => false, :locals => {template_array[-1].to_sym => member}))
          end.join("\n")
        else
          haml(:"#{template}", options)
        end
      end
    end
    
    configure do
      Compass.configuration do |config|
        config.project_path = File.dirname(__FILE__)
        config.sass_dir = 'views'
      end

      set :haml, { :format => :html5 }
      set :sass, Compass.sass_engine_options
      set :scss, Compass.sass_engine_options
    end

    get '/robots.txt' do
      content_type 'text/plain', :charset => 'utf-8'
      <<-EOF
# robots.txt
# See http://en.wikipedia.org/wiki/Robots_exclusion_standard
      EOF
    end

    get '/stylesheets/:sheet.css' do
      content_type 'text/css', :charset => 'utf-8'
      cache scss(:"stylesheets/#{params[:sheet].to_sym}")
    end

    get %r{/attachments/([\w/.-]+)} do
      file = File.join(Nesta::Config.attachment_path, params[:captures].first)
      send_file(file, :disposition => nil)
    end

    get '/articles.xml' do
      content_type :xml, :charset => 'utf-8'
      set_from_config(:title, :subtitle, :author)
      @articles = Page.find_articles.select { |a| a.date }[0..9]
      cache haml(:atom, :format => :xhtml, :layout => false)
    end

    get '/sitemap.xml' do
      content_type :xml, :charset => 'utf-8'
      @pages = Page.find_all
      @last = @pages.map { |page| page.last_modified }.inject do |latest, page|
        (page > latest) ? page : latest
      end
      cache haml(:sitemap, :format => :xhtml, :layout => false)
    end

    get '*' do
      set_common_variables
      @heading = @title
      parts = params[:splat].map { |p| p.sub(/\/$/, '') }
      @page = Nesta::Page.find_by_path(File.join(parts))
      raise Sinatra::NotFound if @page.nil?
      @title = @page.title
      set_from_page(:description, :keywords)
      cache haml(@page.template, :layout => @page.layout)
    end
  end
end
