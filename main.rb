# frozen_string_literal: true

require 'openssl'
require 'sinatra'
require 'httparty'

SCOPES = File.read('scopes')

get '/' do
  puts request.body.rewind
  shop = params['shop']

  # access scopes
  # https://shopify.dev/api/usage/access-scopes
  uri = "https://#{shop}/admin/oauth/authorize?client_id=#{ENV['SHOPIFY_APP_API_KEY']}&scope=#{SCOPES.split.join(',')}&redirect_uri=#{URI.encode_www_form_component(ENV['SHOPIFY_APP_BASE_URL'])}%2Fcallback&state=state"

  redirect uri
end

get '/callback' do
  puts request.body.rewind
  code = params['code']
  shop = params['shop']

  url = "https://#{shop}/admin/oauth/access_token"
  payload = {
    code: code,
    client_id: ENV['SHOPIFY_APP_API_KEY'],
    client_secret: ENV['SHOPIFY_APP_API_SECRET_KEY']
  }

  res = HTTParty.post(url, body: payload)

  puts '*' * 30
  puts res
  puts '*' * 30
end

post '/webhook' do
  request.body.rewind
  data = request.body.read
  puts "HTTP_X_SHOPIFY_HMAC_SHA256: #{env['HTTP_X_SHOPIFY_HMAC_SHA256']}"
  puts "HTTP_X_SHOPIFY_SHOP_DOMAIN: #{env['HTTP_X_SHOPIFY_SHOP_DOMAIN']}"
  puts "HTTP_X_SHOPIFY_TOPIC: #{env['HTTP_X_SHOPIFY_TOPIC']}"

  content_type :json
  result = JSON.parse(data)
  puts result
  result.to_json
end
