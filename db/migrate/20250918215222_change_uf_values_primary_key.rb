class ChangeUfValuesPrimaryKey < ActiveRecord::Migration[8.0]
  def up
    # Elimina la primary key actual (id)
    execute <<-SQL
      ALTER TABLE uf_values DROP CONSTRAINT uf_values_pkey;
    SQL

    # Cambia la columna uf_date a primary key
    execute <<-SQL
      ALTER TABLE uf_values ADD PRIMARY KEY (uf_date);
    SQL

    # Opcional: elimina la columna id si quieres
    remove_column :uf_values, :id
  end

  def down
    # Volver a agregar id como primary key
    add_column :uf_values, :id, :primary_key
    execute <<-SQL
      ALTER TABLE uf_values DROP CONSTRAINT uf_values_pkey;
    SQL
    execute <<-SQL
      ALTER TABLE uf_values ADD PRIMARY KEY (id);
    SQL
  end
end
