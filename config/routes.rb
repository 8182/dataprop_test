Rails.application.routes.draw do

  root "ufs#index" #se deja como root el index, que cargara en el controlador 1 año de valores de la uf

  get "/ufs", to: "ufs#index", as: :ufs
  get '/ufs/search', to: 'ufs#search'
  get '/ufs/busqueda', to: 'ufs#form_by_date'
end
