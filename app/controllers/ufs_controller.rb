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


  def show_by_date #metodo pensando para retornar en json y ser usado con fetch de js, y actualizar dinamicamente desde la vista

  end

end
