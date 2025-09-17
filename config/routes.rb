Rails.application.routes.draw do

  root "ufs#index" #se deja como root el index, que cargara en el controlador 1 año de valores de la uf

  get "/ufs", to: "ufs#index", as: :ufs
  get "/ufs/fecha/:fecha", to: "ufs#show_by_date", as: :by_fecha_ufs
end
