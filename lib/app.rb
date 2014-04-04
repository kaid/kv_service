require "bundler"
Bundler.setup(:default)
require "sinatra"
require "sinatra/cookies"
require "sinatra/reloader"
require 'sinatra/assetpack'
require "pry"
require "sinatra"
require 'haml'
require 'sass'
require 'coffee_script'
require 'yui/compressor'
require 'sinatra/json'
require "rest_client"
require 'mongoid'
require "multi_json"
require File.expand_path("../../config/env",__FILE__)

require "./lib/user_store"
require "./lib/scope"
require "./lib/key_value"
require "./lib/auth"

class KVService < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
  end

  set :views, ["templates"]
  set :root, File.expand_path("../../", __FILE__)
  set :cookie_options, :domain => nil
  register Sinatra::AssetPack

  assets {
    serve '/js', :from => 'assets/javascripts'
    serve '/css', :from => 'assets/stylesheets'

    js :application, "/js/application.js", [
      '/js/jquery-1.11.0.min.js',
      '/js/**/*.js'
    ]

    css :application, "/css/application.css", [
      '/css/**/*.css'
    ]

    css_compression :yui
    js_compression  :uglify
  }

  helpers Sinatra::Cookies

  helpers do
    def current_store
      Auth.current_store(self)
    end

    def kv_res(&block)
      store = UserStore.find_by(secret: params[:secret])
      return 401 if !store
      res = MultiJson.dump({
        key:       params[:key],
        value:     block.call(store),
        user_id:   store.uid,
        user_name: store.name
      })
      content_type :json
      return res if !params[:callback]
      content_type :js
      "#{params[:callback]}(#{res})"
    end
  end

  before do
    headers("Access-Control-Allow-Origin" => request.base_url)
  end

  get "/" do
    redirect to("/login") if !current_store
    haml :index
  end

  get "/login" do
    haml :login
  end

  post "/login" do
    begin
      Auth.new(params[:login], params[:password], self).login!
      200
    rescue
      401
    end
  end

  post "/write" do
    kv_res do |store|
      store.scope(params[:scope]).set(params[:key], params[:value])
    end
  end

  get "/read" do
    kv_res do |store|
      store.scope(params[:scope]).get(params[:key])
    end
  end
end
