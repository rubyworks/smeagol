require 'rss/maker'

module Smeagol
  class RSS
    #
    def initialize(wiki)
      @wiki  = wiki
      @items = []
    end

    #
    def add(name, href, page)
      if md = /^(\d\d\d\d-\d\d-\d\d)/.match(name)
        date = md[1]
        @items << [name, href, date, page]
      end
    end

    def rss
      @rss ||= build_rss
    end

    #
    def build_rss
     ::RSS::Maker.make('2.0') do |maker|
        maker.channel.link         = @wiki.settings.url
        maker.channel.title        = @wiki.settings.title
        maker.channel.description  = @wiki.settings.description.to_s
        maker.channel.author       = @wiki.settings.author.to_s
        maker.channel.updated      = Time.now.to_s
        maker.items.do_sort        = true

        @items.each do |name, href, date, page|
          html = page.formatted_data
          if i = html.index('</p>')
            text = html[0..i+4]
          else
            text = html
          end

          maker.items.new_item do |item|
            item.title = page.title
            item.link  = File.join(@wiki.settings.url, href)
            item.date  = Time.parse(date)
            item.description = text
          end
        end
      end
    end

    #
    def to_s
      rss.to_s
    end
  end
end
