class UfService
  #inicializacion de constantes necesarias
  API_KEY = ENV['CMF_API_KEY']
  BASE_URL = 'https://api.sbif.cl/api-sbifv3/recursos_api/uf'

  #metodo base del servicio, que realizara el get de la data, con argumentos opcionales, y segun los argumentos que vengan realizaremos cierto flujo, o cosntruccion del la url para el request
  def self.fetch(year: nil, month: nil, day: nil, flow: nil, fill_db_with_search: nil)

    #vemos los argumentos que se ingresaron, y los vamos metiendo al path, en caso de venir
    path = BASE_URL.dup # copiamos el valor de la constante, ya que si la asignamos directamente no se podra modificar
    path += "/#{year}" if year
    path += "/#{month.to_s.rjust(2, '0')}" if month #usamos rjust para rellenar a la izquierda con 0 en caso de que se de por ejemplo el value de 1, pasaria a ser 01
    path += "/dias/#{day.to_s.rjust(2, '0')}" if day

    #creamos la url dinamicamente, siempre le damos el argumento de formato como json
    url = URI("#{path}?apikey=#{API_KEY}&formato=json")
    response = Net::HTTP.get(url)
    data = JSON.parse(response)

    if fill_db_with_search
      # si era true, guardamos en db
    end
end