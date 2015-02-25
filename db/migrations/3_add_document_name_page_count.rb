Sequel.migration do
  up do
    # String :uuid, :length => 36, :null => false
    # String :path, :text => true, :null => false
    # DateTime :created_at, :default => Sequel::CURRENT_TIMESTAMP, :null => false
    # primary_key :id
    add_column :documents, :original_name, String
    add_column :documents, :page_count, Integer
  end

  down do
    drop_column :documents, :original_name
    drop_column :documents, :page_count
  end
end