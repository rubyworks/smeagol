module Gollum
  class BlobEntry

    # Gets a File instance for this blob.
    #
    # wiki - Gollum::Wiki instance for the Gollum::Page
    #
    # Returns a Gollum::File instance.
    def file(wiki, commit)
      blob = self.blob(wiki.repo)
      file = wiki.file_class.new(wiki).populate(blob, self.dir)
      file.version = commit
      file
    end

  end
end
