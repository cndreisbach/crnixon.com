require 'redcarpet'

module Nesta
  class Markdown < ::Redcarpet
    def initialize(text)
      super(text, *Nesta::Config.markdown_flags)
    end
  end
end
