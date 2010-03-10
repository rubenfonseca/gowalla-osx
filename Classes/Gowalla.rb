# Gowalla.rb
# Gowalla
#
# Created by Ruben Fonseca on 3/7/10.
# Copyright 2010 __MyCompanyName__. All rights reserved.

require 'uri'
require 'hashie'

class Gowalla
  API = 'http://api.gowalla.com'

  def initialize(username, password)
    @username = username
    @password = password

    @default_options = {
      :credential => { :user => @username, :password => @password },
      :headers => {
        'Accept' => 'application/json, text/javascript, application/json',
        'X-Gowalla-API-Key' => 'feb0123be2754b61b474a41b80d88c38'
      }
    }
  end

  def list_spots(options = {}, &block)
    if options[:sw] && options[:ne]
      options[:order] ||= 'checkins_count desc'
    end

    query = options.map { |k,v| "#{URI.escape(k.to_s)}=#{URI.escape(v.to_s)}" }.join('&')
    MacRubyHTTP.get(API + "/spots?#{query}", @default_options) do |response|
      body = NSString.alloc.initWithData(response.body, encoding:NSASCIIStringEncoding)
      parser = SBJSON.alloc.init

      dict = parser.objectWithString(body, error:nil).map { |item| Hashie::Mash.new(item) }
      block.call(dict)
    end
  end

  def checkin(options = {}, &block)
    options.merge!({
      :post_to_facebook => 0,
      :post_to_twitter => 0,
      :accuracy => 50
      })

      query = options.map { |k,v| "#{URI.escape(k.to_s)}=#{URI.escape(v.to_s)}" }.join('&')
      MacRubyHTTP.post(API + "/checkins", @default_options.merge({ :payload => query })) do |response|
        body = NSString.alloc.initWithData(response.body, encoding:NSASCIIStringEncoding)
        parser = SBJSON.alloc.init

        dict = parser.objectWithString(body, error:nil)
        block.call(Hashie::Mash.new(dict))
      end
    end
  end