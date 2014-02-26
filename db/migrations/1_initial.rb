Sequel.migration do
  change do
    create_table(:documents) do
      String :uuid, :length => 36, :null => false
      String :path, :text => true, :null => false
      DateTime :created_at, :default => Sequel::CURRENT_TIMESTAMP, :null => false
      primary_key :id
    end

    create_table(:document_pages) do
      primary_key :id
      Float :width, :null => false
      Float :height, :null => false
      Integer :number, :null => false
      Integer :rotation, :null => false, :default => 0

      foreign_key :document_id, :documents, :key => :id, :on_delete => :cascade
    end
  end
end
