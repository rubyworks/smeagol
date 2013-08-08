module Gollum
  class File

    #alias :filename :name

    # Populate the Page with information from the Blob.
    #
    # blob - The Grit::Blob that contains the info.
    # path - The String directory path of the page file.
    #
    # Returns the populated Gollum::Page.
    def populate(blob, path=nil)
      @blob = blob
      @path = "#{path}/#{blob.name}"[1..-1]
      self
    end

    #
    attr_reader :wiki

    # Public: The current version of the page.
    #
    # Returns the Grit::Commit.
    attr_accessor :version

    # Recent addition to Gollum.
    #alias filename name unless method_defined?(:filename)

    # Public: The title will be constructed from the
    # filename by stripping the extension and replacing any dashes with
    # spaces.
    #
    # Returns the fully sanitized String title.
    def title
      Sanitize.clean(name).strip
    end

    #
    def extname
      ::File.extname(path)
    end

  end
end
