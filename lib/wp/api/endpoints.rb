module WP::API
  module Endpoints

    def posts(query = {})
      resources('posts', query)
    end

    def post(id, query = {})
      resource('posts', id, query)
    end

    def create_post(data = {})
      resource_post('posts', data)
    end

    def add_post_meta(post_id, data = {})
      resource_post("posts/#{post_id}/meta", data)
    end

    def post_named(slug)
      resource_named('posts', slug)
    end

    def post_meta(id, query = {})
      resource_subpath('posts', id, 'meta', query).first
    end

    def comments(query = {})
      resources('comments', query)
    end

    def comment(id, query = {})
      resource('comments', id, query)
    end

    def create_comment(data = {})
      resource_post('comments', data)
    end

    def categories(query = {})
      sub_resources('terms', 'category', query)
    end

    def tags(query = {})
      sub_resources('terms', 'tag', query)
    end

    def pages(query = {})
      resources('pages', query)
    end

    def page(id, query = {})
      resource('pages', id, query)
    end

    def page_named(slug)
      resource_named('pages', slug)
    end

    def item_named(slug)
      begin
        item = resource_named('posts', slug)
      rescue WP::API::ResourceNotFoundError
        item = resource_named('pages', slug)
      end
    end

    def users(query = {})
      resources('users', query)
    end

    def user(id, query = {})
      resource('users', id, query)
    end

    def media(query = {})
      resources('media', query)
    end

    private

    def resources(res, query = {})
      resources, headers = get_request(res, query)
      resources.collect do |hash|
        klass = resource_class(res)
        klass ? klass.new(hash, headers) : hash
      end
    end

    def resource(res, id, query = {})
      resources, headers = get_request("#{res}/#{id}", query)
      klass = resource_class(res)
      klass ? klass.new(resources, headers) : resources
    end

    def sub_resources(res, sub, query = {})
      resources, headers = get_request("#{res}/#{sub}", query)
      resources.collect do |hash|
        klass = resource_class(sub)
        klass ? klass.new(hash, headers) : hash
      end
    end

    def resource_post(res, data = {})
      resources, headers = post_request("#{res}", data)
      klass = resource_class(res)
      klass ? klass.new(resources, headers) : resources
    end

    def resource_subpath(res, id, subpath, query = {})
      query.merge(should_raise_on_empty: false)
      get_request("#{res}/#{id}/#{subpath}", query)
    end

    def resource_named(res, slug)
      resources(res, name: slug).first
    end

    def resource_class(res)
      WP::API::const_get(res.classify)
    rescue NameError
      nil
    end

  end
end
