#!/usr/bin/env jruby -J-Djava.awt.headless=true
require 'tmpdir'

ENV['TABULA_API_DATABASE_URL'] = "jdbc:sqlite:#{File.expand_path('test.db', File.dirname(__FILE__))}"
ENV['TABULA_DATA_DIR'] = Dir.mktmpdir

require_relative '../lib/tabula_api'
# need to bring the models to the top level namespace
# fixture_dependencies isn't smart enough to resolve
# the constant by itself
Document = TabulaApi::Models::Document
Page = TabulaApi::Models::Page

require 'minitest'
require 'minitest/autorun'
require 'sequel'
require 'rack/test'
require 'fixture_dependencies'

FixtureDependencies.fixture_path = File.expand_path('fixtures',
                                                    File.dirname(__FILE__))

# TabulaApi::DB.loggers << Logger.new($stderr)

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

  def setup
    Document.truncate
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

  def test_upload_document_wrong_media_type
    file = Rack::Test::UploadedFile.new(File.expand_path('fixtures/documents.yml',
                                                         File.dirname(__FILE__)),
                                        'application/pdf')

    post '/documents', :file => file
    assert_equal 415, last_response.status
  end

  def test_get_document_wrong_pattern
    FixtureDependencies.load(:document__document1)
    get '/documents/foobarquuxor'
    assert_equal 404, last_response.status
  end

  def test_get_document_404
    FixtureDependencies.load(:document__document1)
    get '/documents/deadbeef-1ab8-4ec2-8fb2-c7605417e564'
    assert_equal 404, last_response.status
  end

  def test_download_original_document
    upload_file_path = File.expand_path('fixtures/sample.pdf',
                                        File.dirname(__FILE__))
    file = Rack::Test::UploadedFile.new(upload_file_path,
                                        'application/pdf')
    post '/documents', :file => file
    doc = JSON.parse(last_response.body)

    # retrieve uploaded document
    get "/documents/#{doc['uuid']}/document"

    assert_equal File.size(upload_file_path), last_response.headers['Content-Length'].to_i
    assert_equal 'application/pdf', last_response.headers['Content-Type']
  end

  def test_delete_document
    upload_file_path = File.expand_path('fixtures/sample.pdf',
                                        File.dirname(__FILE__))
    file = Rack::Test::UploadedFile.new(upload_file_path,
                                        'application/pdf')
    post '/documents', :file => file
    doc = JSON.parse(last_response.body)

    # get doc object from DB before deleting
    doc_model = TabulaApi::Models::Document.first(uuid: doc['uuid'])

    delete "/documents/#{doc['uuid']}"

    assert !File.exists?(doc_model.document_path)
    assert_equal 0, TabulaApi::Models::Page.where(document_id: doc_model.id).count
  end

  def test_upload_pdf
    upload_file_path = File.expand_path('fixtures/sample.pdf',
                                        File.dirname(__FILE__))
    file = Rack::Test::UploadedFile.new(upload_file_path,
                                        'application/pdf')
    post '/documents', :file => file
    doc = JSON.parse(last_response.body)

    # retrieve uploaded document
    get "/documents/#{doc['uuid']}"
    doc = JSON.parse(last_response.body)

    assert_equal 5, doc['pages'].size
  end

  def test_delete_page
    FixtureDependencies.load(:document__document1)
    delete '/documents/8cf52024-1ab8-4ec2-8fb2-c7605417e564/pages/1'
    assert_equal 0, TabulaApi::Models::Page.where(document: TabulaApi::Models::Document.first(uuid: '8cf52024-1ab8-4ec2-8fb2-c7605417e564')).count
  end

  def test_extract_tables_from_document
    upload_file_path = File.expand_path('fixtures/sample.pdf',
                                        File.dirname(__FILE__))
    file = Rack::Test::UploadedFile.new(upload_file_path,
                                        'application/pdf')
    post '/documents', :file => file
    doc = JSON.parse(last_response.body)

    coords = { 'coords' =>  [ {"left" => 16.97142857142857,
                               "right" => 762.3000000000001,
                               "top" => 53.74285714285715,
                               "bottom" => 548.7428571428571,
                               "page" => 1},
                              {"left" => 16.97142857142857,
                               "right" => 762.3000000000001,
                               "top" => 53.74285714285715,
                               "bottom" => 548.7428571428571,
                               "page" => 2}]
             }

    post "/documents/#{doc['uuid']}/tables.json",
         JSON.dump(coords),
         "CONTENT_TYPE" => 'application/json'

    #puts JSON.parse(last_response.body).inspect

  end

  def test_extract_tables_from_document_page
    upload_file_path = File.expand_path('fixtures/sample.pdf',
                                        File.dirname(__FILE__))
    file = Rack::Test::UploadedFile.new(upload_file_path,
                                        'application/pdf')
    post '/documents', :file => file
    doc = JSON.parse(last_response.body)

    coords = { 'coords' =>  [ {"left" => 16.97142857142857,
                               "right" => 762.3000000000001,
                               "top" => 53.74285714285715,
                               "bottom" => 548.7428571428571}]
             }

    post "/documents/#{doc['uuid']}/pages/1/tables.json",
         JSON.dump(coords),
         "CONTENT_TYPE" => 'application/json'

    #puts JSON.parse(last_response.body).inspect

  end

  def test_autodetected_tables
    upload_file_path = File.expand_path('fixtures/sample.pdf',
                                        File.dirname(__FILE__))
    file = Rack::Test::UploadedFile.new(upload_file_path,
                                        'application/pdf')
    post '/documents', :file => file
    doc = JSON.parse(last_response.body)

    get "/documents/#{doc['uuid']}/tables.json",
         "CONTENT_TYPE" => 'application/json'
    expected = [
                [[18.0, 54.0, 744, 495]], 
                [[18.0, 54.0, 744, 495]], 
                [[18.0, 54.0, 744, 495]], 
                [[18.0, 54.0, 744, 495]], 
                [[18.0, 54.0, 744, 449]]]
    assert_equal expected, JSON.parse(last_response.body)
  end

  def test_autodetected_tables_from_page
    upload_file_path = File.expand_path('fixtures/sample.pdf',
                                        File.dirname(__FILE__))
    file = Rack::Test::UploadedFile.new(upload_file_path,
                                        'application/pdf')
    post '/documents', :file => file
    doc = JSON.parse(last_response.body)

    get "/documents/#{doc['uuid']}/pages/1/tables.json",
         "CONTENT_TYPE" => 'application/json'

    expected = [[18.0, 54.0, 744, 495]]

    assert_equal expected, JSON.parse(last_response.body)
  end

end
