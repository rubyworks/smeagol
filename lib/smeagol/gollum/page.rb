module Gollum

  class Page
    def post?
      /^(\d\d\d\d-\d\d-\d\d)/.match(filename)
    end
  end

  class Markup

    # Attempt to process the tag as a page link tag.
    #
    # tag - The String tag contents (the stuff inside the double
    #       brackets).
    #
    # Returns the String HTML if the tag is a valid page
    # link tag or nil if it is not.
    def process_page_link_tag(tag)
      parts = tag.split('|')
      parts.reverse! if @format == :mediawiki

      name, page_name = *parts.compact.map(&:strip)
      cname = @wiki.page_class.cname(page_name || name)

      if name =~ %r{^https?://} && page_name.nil?
        %{<a href="#{name}">#{name}</a>}
      else
        presence    = "absent"
        link_name   = cname
        page, extra = find_page_from_name(cname)
        if page
          link_name = @wiki.page_class.cname(page.name)
          presence  = "present"
        end
        link = ::File.join(@wiki.base_path, CGI.escape(link_name))

        # TODO: This should be customizable.
        link = link.sub(/^(\d{4}-\d{2}-\d{2}-)/){ |m| m.gsub('-', '/') }

        %{<a class="internal #{presence}" href="#{link}#{extra}">#{name}</a>}
      end
    end

  end

end
