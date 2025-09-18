set :output, "log/cron.log"

# Ejecutar diariamente a las 00:05, usamos la tarea que ya hicimos
every 1.day, at: '00:05' do
  runner "UfService.fetch_today(fill_db_with_search: true)"
end
