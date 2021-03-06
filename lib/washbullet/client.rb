require 'faraday'
require 'mime/types'

require 'washbullet/api'
require 'washbullet/authorization'
require 'washbullet/http_exception'
require 'washbullet/parse_json'
require 'washbullet/request'
require 'washbullet/version'

module Washbullet
  class Client
    include Request
    include API

    ENDPOINT = 'https://api.pushbullet.com'

    attr_reader :api_key

    def initialize(api_key)
      @api_key = api_key
    end

    private

    def connection
      @connection ||= Faraday.new(ENDPOINT, connection_options)
    end

    def connection_options
      @connection_options ||= {
        builder: middleware,
        headers: {
          accept:     'application/json',
          user_agent: "Washbullet Ruby Gem #{Washbullet::VERSION}"
        }
      }
    end

    def middleware
      @middleware ||= Faraday::RackBuilder.new do |f|
        f.request :multipart
        f.request :url_encoded

        f.use Washbullet::Authorization, 'Bearer', api_key
        f.use Washbullet::ParseJSON
        f.use Washbullet::HttpException

        f.adapter :net_http
      end
    end
  end
end
