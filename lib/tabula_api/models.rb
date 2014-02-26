Sequel.connect(ENV['TABULA_API_DATABASE_URL'])

module TabulaAPI
  module Uploaders
    class DocumentUploader < ::CarrierWave::Uploader::Base
      def store_dir
        '/tmp'
      end

      def extension_white_list
        %w(pdf)
      end
    end
  end

  module Models
    class Document < Sequel::Model
      one_to_many :pages, :key => :document_id
      mount_uploader(:path, Uploaders::DocumentUploader)
    end

    class Page < Sequel::Model(:document_pages)
      many_to_one :document, :key => :document_id
    end
  end
end
