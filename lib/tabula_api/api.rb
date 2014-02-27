module TabulaApi
  class REST < Grape::API
    version 'v1', using: :header, vendor: 'tabula'
    format :json

    helpers do
      def job_executor
      end

      def is_valid_pdf?(path)
        File.open(path, 'r') { |f| f.read(4) } == '%PDF'
      end

      def get_document(uuid)
        doc = Models::Document.eager(:pages).first(uuid: uuid)
        error!('Not found', 404) if doc.nil?
        doc
      end

      def doc_to_h(doc)
        doc.values.merge(:pages => doc.pages.map(&:values))
      end
    end

    resource :documents do

      desc "Returns all the documents stored in Tabula"
      get do
        Models::Document.all
      end

      desc "Upload a PDF"
      params do
        requires :file,
                 type: Rack::Multipart::UploadedFile,
                 desc: 'PDF Document'
      end
      post do
        error!('Unsupported media type', 415) unless is_valid_pdf?(params[:file][:tempfile].path)

        doc = nil
        DB.transaction do
          doc = Models::Document.new_from_upload(params[:file])
        end
        doc
      end

      route_param :uuid, requirements: { uuid: /[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}/ } do
        desc "An uploaded document"
        get do
          doc_to_h(get_document(params[:uuid]))
        end

        desc "Download the original PDF"
        get 'document' do
          doc = get_document(params[:uuid])
          content_type 'application/pdf'
          header['Content-Disposition'] = "attachment; filename=#{doc.path}"
          env['api.format'] = :binary
          File.open(doc.document_path).read
        end

        desc "Delete an uploaded document"
        delete do
          doc = get_document(params[:uuid])
          doc.destroy
        end

        desc "Extract tables"
        params do
          requires :coords, type: Array
          optional :extraction_method, type: String, regexp: /^(original|spreadsheet|guess)$/
        end
        post 'tables' do
          doc = get_document(params[:uuid])
          puts Tabula::Extraction::ObjectExtractor.new(doc.document_path).method(:extract).source_location
          extractor = Tabula::Extraction::ObjectExtractor.new(doc.document_path)

          params[:coords]
            .sort_by { |c| c[:page]}
            .group_by { |c| c[:page] }
            .each { |page_number, coords|

            page = extractor.extract_page(page_number)
            puts page.inspect
          }

        end

        resource :pages do
          desc "Delete a page from a document"
          params do
            requires :number, type: Integer, desc: 'Page Number'
          end
          delete ':number', requirements: { number: /\d+/ } do
            doc = get_document(params[:uuid])
            page = doc.pages_dataset.where(number: params[:number]).first
            page.destroy
          end
        end
      end
    end
  end
end
