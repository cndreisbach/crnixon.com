module Nesta
  class Config
    def self.markdown_flags
      flags = from_environment('markdown_flags') || from_yaml('markdown_flags') || []
      if flags.respond_to?(:split)
        flags = flags.split(/\s*,\s*/)
      end
      flags.flatten
    end
  end
end
