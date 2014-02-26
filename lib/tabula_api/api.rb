module TabulaApi
  class REST < Grape::API
    version 'v1', using: :header, vendor: 'tabula'
    format :json

    helpers do

    end

    resource :documents do

      desc "Returns all the documents stored in Tabula"
      get do
        # TODO this should be scoped for the current user
        Models::Document.all
      end

      desc "Upload a PDF"
      post do

      end
    end
  end
end
