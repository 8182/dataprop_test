require 'net/http'
require 'json'

class UfService
  # Inicialización de constantes necesarias
  API_KEY = ENV['CMF_API_KEY']
  BASE_URL = 'https://api.sbif.cl/api-sbifv3/recursos_api/uf'

  # metodo base del servicio, que realizara el get de la data, con argumentos opcionales, y segun los argumentos que vengan realizaremos cierto flujo, o cosntruccion del la url para el request
  def self.fetch(year: nil, month: nil, day: nil, flow: nil, fill_db_with_search: nil)
    path = BASE_URL.dup
    path += "/#{year}" if year
    path += "/#{month.to_s.rjust(2, '0')}" if month
    path += "/dias/#{day.to_s.rjust(2, '0')}" if day

    url = URI("#{path}?apikey=#{API_KEY}&formato=json")

    attempts = 0
    begin
      attempts += 1
      response = Net::HTTP.get(url)
      data = JSON.parse(response)

      if fill_db_with_search
        data['UFs'].each do |uf|
          UfValue.find_or_create_by!(uf_date: uf['Fecha']) do |record|
            record.uf_value = uf['Valor'].to_s.gsub('.', '').gsub(',', '.').to_f
          end
        end
      end

      data
    rescue JSON::ParserError, Net::OpenTimeout, Net::ReadTimeout, SocketError => e
      log_api_error(e, url)
      retry if attempts < 3
      nil
    rescue StandardError => e
      log_api_error(e, url)
      nil
    end
  end

  def self.log_api_error(exception, url)
    Dir.mkdir(Rails.root.join('log/uf_api')) unless Dir.exist?(Rails.root.join('log/uf_api'))
    File.open(Rails.root.join('log/uf_api/uf_errors.log'), 'a') do |f|
      f.puts "[#{Time.now}] ERROR: #{exception.class} - #{exception.message} URL: #{url}"
    end
    Rails.logger.error("UF API Error: #{exception.message}")
  end

  # metodos para consultas mas especificas
  def self.fetch_year(year = Date.today.year)
    fetch(year: year)
  end

  # Obtener UF de hoy
  def self.fetch_today
    today = Date.today
    fetch(year: today.year, month: today.month, day: today.day)
  end

  # Obtener UF de un mes específico
  def self.fetch_month(year, month)
    fetch(year: year, month: month)
  end

  # Obtener UF de un día específico
  def self.fetch_day(year, month, day)
    fetch(year: year, month: month, day: day)
  end
end
