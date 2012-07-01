# TODO: Techincally @pages should probably be called @files since 
#       it includes all files that end up in the site.

require 'rss/maker'

module Smeagol
  class RSS
    #
    # Initialize a new Smeagol::RSS instance.
    #
    def initialize(wiki, options={})
      @wiki    = wiki
      @version = options[:version] || 'master'
      @posts   = options[:posts]
    end

    ##
    ## Collect the items to include in the RSS from the pages.
    ## Only pages with post_dates are included.
    ##
    #def items
    #  list = []
    #  @pages.each do |page|
    #    next unless Smeagol::Views::Page === page
    #    list << page if page.post_date
    #  end
    #  list
    #end

    #
    # Build the RSS instance and cache the result.
    #
    # Returns an RSS::Rss object.
    #
    def rss
      @rss ||= build_rss
    end

    #
    # Build an RSS instance using Ruby's RSS::Maker library.
    #
    # Returns an RSS::Rss object.
    #
    def build_rss
     ::RSS::Maker.make('2.0') do |maker|
        maker.channel.link         = @wiki.settings.url
        maker.channel.title        = @wiki.settings.title
        maker.channel.description  = @wiki.settings.description.to_s
        maker.channel.author       = @wiki.settings.author.to_s
        maker.channel.updated      = Time.now.to_s
        maker.items.do_sort        = true

        posts.each do |post|
          html = post.content
          date = Time.parse(post.post_date)

          next if date > Time.now unless @wiki.settings.future

          if i = html.index('</p>')
            text = html[0..i+4]
          else
            text = html
          end

          maker.items.new_item do |item|
            item.title = post.title
            item.link  = File.join(@wiki.settings.url, post.href)
            item.date  = date
            item.description = text
          end
        end
      end
    end

    #
    # Convert the RSS object to XML string.
    #
    def to_s
      rss.to_s
    end

    #
    def posts
      @posts ||= (
        @wiki.pages.map do |page|
          next unless page.post?
          Smeagol::Views::Post.new(page)
        end.compact
      )
    end

  end

end
