require 'net/http'
require 'date'
require 'json'

module Etcd
  API_VERSION = "v1".freeze
  KEYS_URI = "#{API_VERSION}/keys".freeze

  class << self

    def host= host
      @host = begin
        URI.parse host
        host
      end
    end

    def get key
      url = build_url KEYS_URI, key
      Request.request "GET", url
    end

    def set key, value, options = {}
      url = build_url KEYS_URI, key
      data = {
        value: value,
        ttl: options[:ttl],
        prevValue: options[:prev_value]
      }

      Request.request "POST", url, data: data
    end

    def delete key
      url = build_url KEYS_URI, key
      Request.request "DELETE", url
    end

    def list key
      remove_slash_prefix! key
      url = build_url KEYS_URI, key
      Request.request "GET", url
    end

    def machines
      url = build_url KEYS_URI, "_etcd/machines"
      Request.request "GET", url
    end

    def watch key, options = {}
      remove_slash_prefix! key
      timeout = options[:timeout]
      url = build_url API_VERSION, "watch/%s" % key

      Request.request "GET", url do |req|
        req.read_timeout = timeout if timeout
      end
    end

    private

    def remove_slash_prefix! s
      s.sub!(/^\//,'')
    end

    def build_url sub, key
      remove_slash_prefix! key
      "%s/%s/%s" % [@host, sub, key]
    end

  end

  class Request
    class Error < StandardError
      attr_reader :http_error

      def initialize http_error
        @http_error = http_error
        @data = JSON.parse http_error.body

        super @data["message"]
      end

      def code
        @data["errorCode"]
      end

      def cause
        @data["cause"]
      end
    end

    def self.request method, url, options = {}
      headers = options.fetch :headers, {}
      data = options[:data]
      params = options[:params]
      auth = options[:auth]

      uri = URI.parse url
      uri.query = encode_www_form params if params

      body = process_params headers, data if data

      basic_auth headers, *auth if auth

      response = Net::HTTP.start uri.host, uri.port do |http|
        yield http if block_given?
        http.send_request method, uri.path, body, headers
      end

      if response.code.to_i == 301
        request method, response.header["location"], options
      else
        raise Error.new(response) unless response.is_a? Net::HTTPSuccess
        Response.new response.code, response.to_hash, response.body
      end
    end

    def self.encode_www_form params
      URI.encode_www_form params
    end

    def self.process_params headers, data
      if not data.kind_of? Enumerable
        data
      else
        headers['content-type'] = 'application/x-www-form-urlencoded'
        encode_www_form data
      end
    end
  end

  class Response
    attr_reader :status, :headers, :body, :data, :records

    def initialize status, headers, body
      @status = status.to_i
      @headers = headers
      @body = body
      @data = JSON.parse @body, symbolize_names: true
      @data = [@data] if @data.is_a? Hash
      @records = @data.collect { |rec| Record.new rec }
    end

    def record
      @records.first
    end
  end

  class Record < Hash
    def initialize data
      update data
    end

    def prev_value
      self[:prevValue]
    end

    def expires_at
      @expires_at ||= unless self[:expiration].nil?
        DateTime.parse self[:expiration]
      end
    end

    def expires?
      not expires_at.nil?
    end
  end
end
