require 'net/http'
require 'json'

class UfService
  #inicializacion de constantes necesarias
  API_KEY = '23718e110a103b8d2350c69388a320ff0d9395f1'
  # API_KEY = ENV['CMF_API_KEY']
  BASE_URL = 'https://api.sbif.cl/api-sbifv3/recursos_api/uf'


  # Método base
  def self.fetch(year: nil, month: nil, day: nil, flow: nil, fill_db_with_search: nil)

    path = BASE_URL.dup
    path += "/posteriores" if flow == :posteriores
    path += "/anteriores" if flow == :anteriores
    path += "/periodo" if flow == :periodo
    path += "/#{year}" if year
    path += "/#{month.to_s.rjust(2, '0')}" if month
    path += "/dias/#{day.to_s.rjust(2, '0')}" if day

    url = URI("#{path}?apikey=#{API_KEY}&formato=json")
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
  rescue => e
    Rails.logger.error("Error fetching UF for #{year}-#{month}-#{day}: #{e.message}")
    nil
  end

  # Métodos de conveniencia
  def self.fetch_year(year = Date.today.year, fill_db_with_search: nil)
    fetch(year: year, fill_db_with_search: fill_db_with_search)
  end

  def self.fetch_today(fill_db_with_search: nil)
    today = Date.today
    fetch(year: today.year, month: today.month, day: today.day, fill_db_with_search: fill_db_with_search)
  end

  def self.fetch_month(year, month, fill_db_with_search: nil)
    fetch(year: year, month: month, fill_db_with_search: fill_db_with_search)
  end

  def self.fetch_day(year, month, day, fill_db_with_search: nil)
    fetch(year: year, month: month, day: day, fill_db_with_search: fill_db_with_search)
  end
end



