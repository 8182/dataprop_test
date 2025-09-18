class UfsController < ApplicationController

  def index
    #partimos por cargar 1 año de los valores de la uf para presentarlos en el home/index
    start_date = Date.today - 1.year
    end_date = Date.today

    # calcular segundos que faltan hasta las 00:00, para invalidar el cache y generar uno nuevo con la consulta que tomaria desde el dia nuevo hasta 1 año atras
    expires_in = (Time.current.end_of_day - Time.current).to_i

    #consulta a la api a travez de un servicio, agregandole el cache y la expiracion de este calculado
    @ufs = Rails.cache.fetch("ufs_#{start_date}_#{end_date}", expires_in: expires_in) do
      # Llamamos al servicio para el año completo
      data = UfService.fetch(year: start_date.year, fill_db_with_search: false)

      data['UFs'].map do |uf|
        { fecha: uf['Fecha'], uf_value: uf['Valor'].to_s.gsub('.', '').gsub(',', '.').to_f }
      end
    end
  end

  #vista con el form para buscar fechas 
  def form_by_date
    today = Date.today

    # cache para valor de hoy
    expires_in_today = (Time.current.end_of_day - Time.current).to_i

    #generamos un cache con mismo funcionamiento que en el index
    @uf_today = Rails.cache.fetch("uf_#{today}", expires_in: expires_in_today) do
      data = UfService.fetch(year: today.year, month: today.month, day: today.day, fill_db_with_search: false)
      uf = data && data["UFs"]&.first
      uf ? { fecha: uf["Fecha"], valor: uf["Valor"].to_s.gsub('.', '').gsub(',', '.').to_f } : nil
    end

    # como fallback, si la api responde nil para el dia, se tomara el valor del dia anterior, y se creara la variable @var con valor, para mostrar en el front que hubo este cambio 
    if @uf_today.nil?
      yesterday = today - 1.day
      @uf_today = Rails.cache.fetch("uf_#{yesterday}", expires_in: 1.year) do
        data = UfService.fetch(year: yesterday.year, month: yesterday.month, day: yesterday.day, fill_db_with_search: false)
        uf = data && data["UFs"]&.first
        uf ? { fecha: uf["Fecha"], valor: uf["Valor"].to_s.gsub('.', '').gsub(',', '.').to_f } : nil
      end
      @var = "Mostrando UF del día anterior (#{yesterday})"
    else
      @var = nil
    end

  end

  # metodo que se usara con fetch desde el front de form_by_date
  def search

  end

end
