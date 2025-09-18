class UfsController < ApplicationController

  def index
    start_date = Date.today - 1.year
    end_date = Date.today

    expires_in = (Time.current.end_of_day - Time.current).to_i

    @ufs = Rails.cache.fetch("ufs_#{start_date}_#{end_date}", expires_in: expires_in) do
      data = UfService.fetch(year: start_date.year, fill_db_with_search: false)
      
      data['UFs'].map do |uf|
        # Convertir a formato YYYY-MM-DD para que coincida con @usd_values
        fecha_normalizada = Date.parse(uf['Fecha']).strftime('%Y-%m-%d')
        { 
          uf_date: fecha_normalizada,
          uf_value: uf['Valor'].to_s.gsub('.', '').gsub(',', '.').to_f 
        }
      end
    end

    @usd_values = Rails.cache.fetch("usd_#{start_date}_#{end_date}", expires_in: 12.hours) do
      DollarService.fetch_range(start_date, end_date)
    end

    @dolar_hoy = @usd_values[Date.today.strftime('%Y-%m-%d')]
  end

  # vista con el form para buscar fechas
  def form_by_date
    today = Date.today

    # cache para valor de hoy
    expires_in_today = (Time.current.end_of_day - Time.current).to_i

    # generamos un cache con mismo funcionamiento que en el index
    @uf_today = Rails.cache.fetch("uf_#{today}", expires_in: expires_in_today) do
      data = UfService.fetch(year: today.year, month: today.month, day: today.day, fill_db_with_search: false)
      uf = data && data['UFs']&.first
      uf ? { fecha: uf['Fecha'], valor: uf['Valor'].to_s.gsub('.', '').gsub(',', '.').to_f } : nil
    end

    # como fallback, si la api responde nil para el dia, se tomara el valor del dia anterior, y se creara la variable @var con valor, para mostrar en el front que hubo este cambio
    if @uf_today.nil?
      yesterday = today - 1.day
      @uf_today = Rails.cache.fetch("uf_#{yesterday}", expires_in: 1.year) do
        data = UfService.fetch(year: yesterday.year, month: yesterday.month, day: yesterday.day,
                               fill_db_with_search: false)
        uf = data && data['UFs']&.first
        uf ? { fecha: uf['Fecha'], valor: uf['Valor'].to_s.gsub('.', '').gsub(',', '.').to_f } : nil
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
    save  = params[:save_to_db].to_s == '1'

    # vemos que datos venian en los params y en base a eso usamos cierto metodo del servicio, siempre debe venir el año, eso lo validamos en el front
    if day && month && year # busqueda exacta por dia
      fecha = Date.new(year.to_i, month.to_i, day.to_i)
      @uf = fetch_day(fecha, save)
      result = if @uf
                # Obtener valor USD para esta fecha
                usd_value = fetch_usd_value(fecha)
                { 
                  fecha: @uf[:fecha], 
                  valor: @uf[:valor],
                  valor_usd: usd_value,
                  valor_uf_usd: usd_value ? (@uf[:valor] / usd_value).round(4) : nil
                }
              else
                { error: 'UF no encontrada' }
              end

    elsif month && year # busqueda por año y mes
      start_date = Date.new(year.to_i, month.to_i, 1)
      end_date   = start_date.end_of_month
      @ufs = fetch_range(start_date, end_date, save)
      result = if @ufs.any?
                # Obtener valores USD para el rango
                usd_values = fetch_usd_range(start_date, end_date)
                @ufs.map do |uf|
                  fecha = Date.parse(uf[:fecha])
                  usd_value = usd_values[fecha.strftime('%Y-%m-%d')]
                  {
                    fecha: uf[:fecha],
                    valor: uf[:valor],
                    valor_usd: usd_value,
                    valor_uf_usd: usd_value ? (uf[:valor] / usd_value).round(4) : nil
                  }
                end
              else
                { error: 'UF no encontrada' }
              end

    elsif year
      start_date = Date.new(year.to_i, 1, 1)
      end_date   = start_date.end_of_year
      @ufs = fetch_range(start_date, end_date, save)
      result = if @ufs.any?
                # Obtener valores USD para el rango
                usd_values = fetch_usd_range(start_date, end_date)
                @ufs.map do |uf|
                  fecha = Date.parse(uf[:fecha])
                  usd_value = usd_values[fecha.strftime('%Y-%m-%d')]
                  {
                    fecha: uf[:fecha],
                    valor: uf[:valor],
                    valor_usd: usd_value,
                    valor_uf_usd: usd_value ? (uf[:valor] / usd_value).round(4) : nil
                  }
                end
              else
                { error: 'UF no encontrada' }
              end

    else
      result = { error: 'Debe enviar al menos el año' }
    end

    render json: result
  end

  private

  # Nuevos métodos para obtener valores USD
  def fetch_usd_value(date)
    cache_key = "usd_#{date}"
    Rails.cache.fetch(cache_key, expires_in: 12.hours) do
      DollarService.fetch_range(date, date)[date.strftime('%Y-%m-%d')]
    end
  end

  def fetch_usd_range(start_date, end_date)
    cache_key = "usd_#{start_date}_#{end_date}"
    Rails.cache.fetch(cache_key, expires_in: 12.hours) do
      DollarService.fetch_range(start_date, end_date)
    end
  end

  private

  # metodo privado para busqueda solo para un dia en especifico, ademas maneja el flujo si se guarda la data o no
  def fetch_day(fecha, save)
    cache_key = "uf_#{fecha}" # key del cache

    # intentamos leer del cache, si no exsite se hara la consulta
    Rails.cache.fetch(cache_key, expires_in: 1.day) do
      # si save es true, también actualizamos la DB
      data = if save
               UfService.fetch(year: fecha.year, month: fecha.month, day: fecha.day, fill_db_with_search: true)
             else
               UfService.fetch(year: fecha.year, month: fecha.month, day: fecha.day, fill_db_with_search: false)
             end

      uf_data = data['UFs']&.first
      uf_data ? { fecha: uf_data['Fecha'], valor: uf_data['Valor'].to_s.gsub('.', '').gsub(',', '.').to_f } : nil
    end
  end

  # Trae un rango de fechas (mes o año)
  def fetch_range(start_date, end_date, save)
    cache_key = "ufs_#{start_date}_#{end_date}_#{save ? 'db' : 'api'}"

    Rails.cache.fetch(cache_key, expires_in: 12.hours) do
      results = []
      (start_date..end_date).each do |fecha|
        uf = fetch_day(fecha, save)
        results << uf if uf
      end
      results
    end
  end
end
