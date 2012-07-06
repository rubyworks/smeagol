module Gollum
  class Wiki

    # Public: Lists all non-page files for this wiki.
    #
    # treeish - The String commit ID or ref to find  (default:  @ref)
    #
    # Returns an Array of Gollum::File instances.
    def files(treeish = nil)
      file_list(treeish || @ref)
    end

    # Fill an array with a list of files.
    #
    # ref - A String ref that is either a commit SHA or references one.
    #
    # Returns a flat Array of Gollum::File instances.
    def file_list(ref)
      if sha = @access.ref_to_sha(ref)
        commit = @access.commit(sha)
        tree_map_for(sha).inject([]) do |list, entry|
          next list if @page_class.valid_page_name?(entry.name)
          list << entry.file(self, commit)
        end
      else
        []
      end
    end

  end
end
