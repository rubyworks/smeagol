module Smeagol

  class Cache

    #
    # Creates a cache object for a Gollum wiki.
    #
    # wiki - The wiki to cache. [Wiki]
    #
    # Returns cache. [Cache]
    #
    def initialize(wiki)
      @wiki = wiki
      @path = "#{Dir.tmpdir}/smeagol/#{File.expand_path(@wiki.path)}"
    end

    #
    # The cached wiki.
    #
    attr_reader :wiki
    
    #
    # The path to the smeagol cache for this wiki.
    #
    attr_accessor :path

    #
    # Clears the entire cache.
    #
    def clear
      FileUtils.rm_rf(path)
    end

    #
    # Checks if a cache hit is found for a given gollum page.
    #
    # name    - The name of the page to check.    [String]
    # version - The version of the page to check. [String]
    #
    # Returns true if the page has been cached, otherwise false. [Boolean]
    #
    def cache_hit?(name, version='master')
      page = wiki.page(name, version)
      File.exists?(page_path(name, version)) unless page.nil?
    end

    #
    # Retrieves the content of the cached page.
    #
    # name    - The name of the wiki page. [String]
    # version - The version of the page.   [String]
    #
    # Returns the contents of the HTML page if cached, otherwise nil. [String,nil]
    #
    def get_page(name, version='master')
      IO.read(page_path(name, version)) if cache_hit?(name, version)
    end

    #
    # Sets the cached content for a page.
    #
    # name    - The name of the wiki page. [String]
    # version - The version of the page.   [String]
    # content - The content to cache.      [String]
    #
    # Returns nothing.
    #
    def set_page(name, version, content)
      $stderr.puts "set page: #{name} : #{version.class}" unless $QUIET
      page = wiki.page(name, version)
      if !page.nil?
        path = page_path(name, version)
        FileUtils.mkdir_p(File.dirname(path))
        File.open(path, 'w') do |f|
          f.write(content)
        end
      end
    end

    #
    # Removes the cached content for a page.
    #
    # name    - The name of the wiki page. [String]
    # version - The version of the page.   [String] 
    #
    # Returns nothing.
    #
    def remove_page(name, version='master')
      page = wiki.page(name, version)
      File.delete(page_path(name, version)) if !page.nil? && File.exists?(page_path(name, version))
    end

    #
    # Retrieves the path to the cache for a given page.
    #
    # name    - The name of the wiki page. [String]
    # version - The version of the page.   [String] 
    #
    # Returns the file path to the cached wiki page. [String]
    #
    def page_path(name, version='master')
      page = wiki.page(name, version)
      if !page.nil?
        "#{path}/#{page.path}/#{page.version.id}"
      end
    end

  end

end
