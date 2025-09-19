class FixUfValuesPrimaryKey < ActiveRecord::Migration[8.0]
  def up
    # Primero eliminar la primary key actual en uf_date
    execute <<-SQL
      ALTER TABLE uf_values DROP CONSTRAINT uf_values_pkey;
    SQL

    # Agregar la columna id como serial (auto-increment)
    add_column :uf_values, :id, :primary_key

    # Verificar si el índice ya existe antes de crearlo
    unless index_exists?(:uf_values, :uf_date, unique: true)
      add_index :uf_values, :uf_date, unique: true
    end
  end

  def down
    # Eliminar el índice único si existe
    if index_exists?(:uf_values, :uf_date, unique: true)
      remove_index :uf_values, :uf_date
    end

    # Eliminar la columna id
    remove_column :uf_values, :id

    # Restaurar uf_date como primary key
    execute <<-SQL
      ALTER TABLE uf_values ADD PRIMARY KEY (uf_date);
    SQL
  end
end