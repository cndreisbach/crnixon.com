require 'redcarpet'

module Haml::Filters::Markdown
  include Haml::Filters::Base
  
  def render(text)
    markdown = ::Nesta::Markdown.new(text)
    return markdown.to_html
  end
end 

