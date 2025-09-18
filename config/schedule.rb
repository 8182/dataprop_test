set :output, 'log/cron.log'

# Ejecutar diariamente a las 00:05
every 1.day, at: '00:05' do
  runner <<-RUBY
    today = Date.today
    UfService.fetch_today(fill_db_with_search: true) # actualiza DB
    Rails.cache.delete("uf_\#{today}") # invalida cache del día
  RUBY
end
