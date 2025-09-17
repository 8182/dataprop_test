ActiveRecord::Schema[8.0].define(version: 2025_09_17_171115) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "uf_values", force: :cascade do |t|
    t.date "uf_date", null: false
    t.decimal "uf_value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uf_date"], name: "index_uf_values_on_uf_date", unique: true
  end
end
