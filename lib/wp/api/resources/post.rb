require 'htmlentities'

module WP::API
  class Post < Resource
    def post_id
      attributes['ID']
    end

    def title
      _remove_entities(super)
    end

    def content
      _remove_entities(super)
    end

    def categories(client = nil, query = {})
      return if client.nil?
      attributes['categories'] ||= client.categories query.merge(post: id)
    end

    def tags(client = nil, query = {})
      return if client.nil?
      attributes['tags'] ||= client.tags query.merge(post: id)
    end

    def author(client = nil, query = {})
      return if client.nil?
      attributes['author_data'] ||= client.user attributes['author'], query
    end

    def prev
      item = link_header_items.find {|rel, url| rel == "prev" }
      item.last if item
    end

    def next
      item = link_header_items.find {|rel, url| rel == "next" }
      item.last if item
    end

    def items
      items = link_header_items.select {|rel, url| rel == "item" }
      items.empty? ? [] : items.collect(&:last)
    end

    private

    def link_header_items
      @link_header_items ||= headers['link'].split(', ').collect do |header|
        [
          header.match(/rel="([^"]+)"/)[1],
          header.match(/<([^>]+)>/)[1]
        ]
      end
    rescue
      []
    end
  end
end
