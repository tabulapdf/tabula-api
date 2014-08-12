Sequel.migration do
  up do
    add_column :documents, :size, Integer
  end

  down do
    drop_column :documents, :size
  end
end
