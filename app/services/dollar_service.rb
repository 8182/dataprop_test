# app/services/dollar_service.rb
require 'net/http'
require 'json'
require 'uri'

class DollarService
  API_KEY_DOLAR = ENV['API_KEY_DOLAR']

  # fetch USD values for a range of years
  def self.fetch_range(start_date, end_date)
    start_year = start_date.year
    end_year = end_date.year

    url = URI("https://api.sbif.cl/api-sbifv3/recursos_api/dolar/periodo/#{start_year}/#{end_year}?apikey=#{API_KEY_DOLAR}&formato=json")
    response = Net::HTTP.get(url)
    

    begin
      data = JSON.parse(response)
      
    rescue JSON::ParserError => e
      Rails.logger.error("DollarService.fetch_range JSON parse error: #{e.message}")
      return {}
    end

    usd_values = {}
    if data['Dolares'].is_a?(Array)
      data['Dolares'].each do |d|
        next unless d['Fecha'] && d['Valor']

        date = d['Fecha']                           # "YYYY-MM-DD"
        value = d['Valor'].to_s.gsub('.', '').gsub(',', '.').to_f
        usd_values[date] = value
      end
    end

    usd_values
  end

  # fetch USD value for today
  def self.today
    url = URI("https://api.sbif.cl/api-sbifv3/recursos_api/dolar?apikey=#{API_KEY_DOLAR}&formato=json")
    response = Net::HTTP.get(url)

    begin
      data = JSON.parse(response)
    rescue JSON::ParserError => e
      Rails.logger.error("DollarService.today JSON parse error: #{e.message}")
      return nil
    end

    if data['Dolares'].is_a?(Array) && data['Dolares'][0] && data['Dolares'][0]['Valor']
      value = data['Dolares'][0]['Valor'].to_s.gsub('.', '').gsub(',', '.').to_f
      return value
    end

    nil
  end
end
