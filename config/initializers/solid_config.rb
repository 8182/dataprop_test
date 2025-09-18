# Configuración segura para solid_* gems
Rails.application.config.after_initialize do
  if defined?(SolidCable)
    Rails.application.config.solid_cable.enabled = false
  end
  
  if defined?(SolidCache)
    Rails.application.config.solid_cache.enabled = false
  end
  
  if defined?(SolidQueue)
    Rails.application.config.solid_queue.enabled = false
  end
end