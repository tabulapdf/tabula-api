ENV['TABULA_API_DATABASE_URL'] = "jdbc:sqlite:#{File.expand_path('test.db', File.dirname(__FILE__))}"

require_relative '../lib/tabula_api'
require 'sequel'
require 'minitest'
require 'minitest/autorun'
require 'rack/test'
require 'fixture_dependencies'

FixtureDependencies.fixture_path = File.expand_path('fixtures',
                                                    File.dirname(__FILE__))

# need to bring the models to the top level namespace
# fixture_dependencies isn't smart enough to resolve
# the constant by itself
include TabulaApi::Models

class TabulaApiTestCase < MiniTest::Test
  include Rack::Test::Methods

  def run(*args, &block)
    result = nil
    Sequel::Model.db.transaction(:rollback=>:always) { result = super }
    result
  end

  def app
    TabulaApi::REST
  end

end

class TabulaApiTests < TabulaApiTestCase

  def test_documents_collection
    FixtureDependencies.load(:document__document1)
    get '/documents'
    assert_equal 200, last_response.status
    resp = JSON.parse(last_response.body)
    assert_equal 1, resp.size
    assert_equal '8cf52024-1ab8-4ec2-8fb2-c7605417e564', resp.first['uuid']
  end

  def test_upload_document
    file = fixture_file_upload('fixtures/sample.pdf', 'application/pdf')
    post '/documents', :file => file
    raise "not finished"
  end

end
