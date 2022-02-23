# frozen_string_literal: true

require 'shopify_api'

shopify_session = ShopifyAPI::Session.new(
  domain: ENV['SHOPIFY_SHOP_DOMAIN'],
  token: ENV['SHOPIFY_SHOP_TOKEN'],
  api_version: ENV['SHOPIFY_API_VERSION']
)
ShopifyAPI::Base.activate_session(shopify_session)
ShopifyAPI::GraphQL.initialize_clients
client = ShopifyAPI::GraphQL.client

query_string = File.read('query.gql')
variables_json = File.read('variables.json')
variables = JSON.parse(variables_json)

query = client.parse(query_string)
result = client.query(query, variables: variables)

puts JSON.pretty_generate(result.data.to_h)
puts JSON.pretty_generate(result.extensions.to_h)
puts JSON.pretty_generate(result.errors.to_h)
