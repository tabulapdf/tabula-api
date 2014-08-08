require 'securerandom'

module TabulaApi
  DB = Sequel.connect("jdbc:sqlite://" + File.join(Settings.getDataDir, 'tabula_api.db'))
  Sequel::Model.plugin :json_serializer

  module Models
    class Document < Sequel::Model
      one_to_many :pages, :key => :document_id
      attr_accessor :uploaded_file

      def after_create
        return if self.uploaded_file.nil?
        FileUtils.mkdir_p(File.dirname(self.document_path))
        begin
          FileUtils.mv(self.uploaded_file,
                       self.document_path)
        rescue Errno::EACCES # mv fails on Windows sometimes
          FileUtils.cp_r(self.uploaded_file,
                         self.document_path)
          FileUtils.rm_rf(self.uploaded_file)
        end
      end

      def before_destroy
        FileUtils.rm_rf(File.dirname(self.document_path))
      end

      def document_path
        File.join(Settings.getDataDir, 'pdfs', self.uuid, 'document.pdf')
      end

      class << self
        def new_from_upload(uploaded_file)
          doc = self.create(:uuid => SecureRandom.uuid,
                            :path => uploaded_file[:filename],
                            :uploaded_file => uploaded_file[:tempfile].path)
          Tabula::Extraction::PagesInfoExtractor.new(doc.document_path).pages.each do |p|
            doc.add_page(Page.new(:width => p.width,
                                  :height => p.height,
                                  :rotation => p.rotation,
                                  :number => p.number_one_indexed))
          end
          doc
        end
      end
    end

    class Page < Sequel::Model(:document_pages)
      many_to_one :document, :key => :document_id
    end
  end
end
