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
    day   = params[:day].presence
    month = params[:month].presence
    year  = params[:year].presence
    save  = params[:save_to_db].to_s == "1" 

    #vemos que datos venian en los params y en base a eso usamos cierto metodo del servicio, siempre debe venir el año, eso lo validamos en el front
    if day && month && year #busqueda exacta por dia 
      fecha = Date.new(year.to_i, month.to_i, day.to_i) 
      @uf = fetch_day(fecha, save)
      result = @uf ? { fecha: @uf[:fecha], valor: @uf[:valor] } : { error: "UF no encontrada" }

    elsif month && year #busqueda por año y mes
      start_date = Date.new(year.to_i, month.to_i, 1)
      end_date   = start_date.end_of_month
      @ufs = fetch_range(start_date, end_date, save)
      result = @ufs.any? ? @ufs : { error: "UF no encontrada" }

    elsif year
      start_date = Date.new(year.to_i, 1, 1)
      end_date   = start_date.end_of_year
      @ufs = fetch_range(start_date, end_date, save)
      result = @ufs.any? ? @ufs : { error: "UF no encontrada" }

    else
      result = { error: "Debe enviar al menos el año" }
    end

    render json: result
  end

  private

  #metodo privado para busqueda solo para un dia en especifico, ademas maneja el flujo si se guarda la data o no
  def fetch_day(fecha, save)
    cache_key = "uf_#{fecha}" #key del cache

    # intentamos leer del cache, si no exsite se hara la consulta
    Rails.cache.fetch(cache_key, expires_in: 1.day) do
      # si save es true, también actualizamos la DB
      if save
        data = UfService.fetch(year: fecha.year, month: fecha.month, day: fecha.day, fill_db_with_search: true)
      else
        data = UfService.fetch(year: fecha.year, month: fecha.month, day: fecha.day, fill_db_with_search: false)
      end

      uf_data = data["UFs"]&.first
      uf_data ? { fecha: uf_data["Fecha"], valor: uf_data["Valor"].to_s.gsub('.', '').gsub(',', '.').to_f } : nil
    end
  end

  # Trae un rango de fechas (mes o año)
  def fetch_range(start_date, end_date, save)
    results = []
    (start_date..end_date).each do |fecha|
      uf = fetch_day(fecha, save)
      results << uf if uf
    end
    results
  end

end
