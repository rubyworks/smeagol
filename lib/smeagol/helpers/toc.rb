module Smeagol

  # Create a JSON-based Table of Contents.
  # This is used to create 'toc.json', which can
  # be used via jQuery to create a dynamic index
  # page.
  # 
  class TOC

    #
    def initialize(ctrl, options={})
      @ctrl    = ctrl
      @wiki    = ctrl.wiki
      @version = options[:version] || 'master' 
      @pages   = options[:pages]

      require 'json'
    end

    #
    def to_json
      toc.to_json
    end

    #
    alias to_s to_json

    #
    def toc
      @toc ||= build_toc
    end

    #
    def build_toc
      json = {}
      pages.each do |page|
        data = {}
        data['title']   = page.title
        data['name']    = page.name
        data['href']    = page.href
        data['date']    = page.post_date if page.post_date
        data['author']  = page.author
        data['summary'] = page.summary
        json[page.name] = data
      end
      json
    end

    #
    def pages
      @ctrl.views(@version).reject{ |v| Smeagol::Views::Form === v }
    end

    #
    #def pages
    #  @pages ||= (
    #    @wiki.pages.map do |page|
    #      if page.post?
    #        Smeagol::Views::Post.new(page)
    #      else
    #        Smeagol::Views::Page.new(page)
    #      end
    #    end
    #  )
    #end

  end

end
