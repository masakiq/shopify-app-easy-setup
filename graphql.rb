# frozen_string_literal: true

require 'shopify_api'
require 'fileutils'

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

def out_result_temporary(result)
  out_file = File.new('tmp/tmp_result.json', 'w')
  out_file.puts(result.to_h.to_json)
  out_file.close
  system('cat tmp/tmp_result.json | jq > tmp/result.json')
end

def should_record_history?
  histories = Dir.glob('histories/*').sort
  return true if histories.empty?
  return true unless FileUtils.cmp("#{histories.last}/query.gql", 'query.gql')
  return true unless FileUtils.cmp("#{histories.last}/variables.json", 'variables.json')
  return true unless FileUtils.cmp("#{histories.last}/result.json", 'tmp/result.json')

  false
end

def delete_old_file
  histories = Dir.glob('histories/*').sort
  count = histories.size - 100
  return if count.negative?

  count.times do
    FileUtils.rm_r(histories.first)
    histories.delete_at(0)
  end
end

def record_history_with_current_time
  current_time = Time.now.to_i
  Dir.mkdir("histories/#{current_time}")
  FileUtils.cp('query.gql', "histories/#{current_time}/query.gql")
  FileUtils.cp('variables.json', "histories/#{current_time}/variables.json")
  FileUtils.cp('tmp/result.json', "histories/#{current_time}/result.json")
end

def record_history(result)
  out_result_temporary(result)
  return unless should_record_history?

  record_history_with_current_time
  delete_old_file
end

query = client.parse(query_string)
result = client.query(query, variables: variables)
response = JSON.pretty_generate(result.to_h)
puts response

record_history(result)
