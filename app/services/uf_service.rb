require 'net/http'
require 'json'

class UfService
  # Inicialización de constantes necesarias
  API_KEY = ENV['CMF_API_KEY']
  BASE_URL = 'https://api.sbif.cl/api-sbifv3/recursos_api/uf'

  #metodo base del servicio, que realizara el get de la data, con argumentos opcionales, y segun los argumentos que vengan realizaremos cierto flujo, o cosntruccion del la url para el request
  def self.fetch(year: nil, month: nil, day: nil, flow: nil, fill_db_with_search: nil)

    #vemos los argumentos que se ingresaron, y los vamos metiendo al path, en caso de venir
    path = BASE_URL.dup # copiamos el valor de la constante, ya que si la asignamos directamente no se podra modificar

    #api ofrece estos endpoints, pero no parecen ser requerido por los requerimientos por ahora, se deja comentado 
    # path += "/posteriores" if flow == :posteriores
    # path += "/anteriores" if flow == :anteriores
    # path += "/periodo" if flow == :periodo

    path += "/#{year}" if year
    path += "/#{month.to_s.rjust(2, '0')}" if month
    path += "/dias/#{day.to_s.rjust(2, '0')}" if day

    # Construimos la URL final con API key y formato JSON
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
    Rails.logger.error("Error fetching UF data: #{e.message}")
    nil
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
