require 'fileutils'

module Smeagol
  class Cache
    # Creates a cache object for a Gollum wiki.
    #
    # wiki - The wiki to cache.
    #
    # Returns a Smeagol::Cache object.
    def initialize(wiki)
      @wiki = wiki
      @path = "#{Dir.tmpdir}/smeagol/#{File.expand_path(@wiki.path)}"
    end
    
    # The cached wiki.
    attr_reader :wiki
    
    # The path to the smeagol cache for this wiki.
    attr_accessor :path


    # Clears the entire cache.
    def clear
      FileUtils.rm_rf(path)
    end
    
    # Checks if a cache hit is found for a given gollum page.
    #
    # name - The name of the page to check.
    #
    # Returns true if the page has been cached, otherwise returns false.
    def cache_hit?(name)
      page = wiki.page(name)
      File.exists?(page_path(name)) unless page.nil?
    end
    
    # Retrieves the content of the cached page.
    #
    # name - The name of the wiki page.
    #
    # Returns the contents of the HTML page if cached. Otherwise returns nil.
    def get_page(name)
      IO.read(page_path(name)) if cache_hit?(name)
    end

    # Sets the cached content for a page.
    #
    # name    - The name of the wiki page.
    # content - The content to cache.
    #
    # Returns nothing.
    def set_page(name, content)
      page = wiki.page(name)
      if !page.nil?
        FileUtils.mkdir_p(File.dirname(page_path(name)))
        File.open(page_path(name), 'w') do |f|
          f.write(content)
        end
      end
    end

    # Removes the cached content for a page.
    #
    # name    - The name of the wiki page.
    #
    # Returns nothing.
    def remove_page(name)
      page = wiki.page(name)
      File.delete(page_path(name)) if !page.nil? && File.exists?(page_path(name))
    end
    
    # Retrieves the path to the cache for a given page.
    #
    # name - The name of the wiki page.
    #
    # Returns a file path to the cached wiki page.
    def page_path(name)
      page = wiki.page(name)
      if !page.nil?
        "#{path}/#{page.path}/#{page.version}"
      end
    end
  end
end
