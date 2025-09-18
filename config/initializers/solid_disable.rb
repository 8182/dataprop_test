# Configuración ultra-segura para deshabilitar solid_* gems
Rails.application.reloader.to_prepare do
  begin
    if defined?(SolidCable) && Rails.application.config.respond_to?(:solid_cable)
      Rails.application.config.solid_cable.enabled = false
    end
  rescue NoMethodError, NameError
    # Ignorar silenciosamente si la configuración no está disponible
  end

  begin
    if defined?(SolidCache) && Rails.application.config.respond_to?(:solid_cache)
      Rails.application.config.solid_cache.enabled = false
    end
  rescue NoMethodError, NameError
    # Ignorar silenciosamente si la configuración no está disponible
  end

  begin
    if defined?(SolidQueue) && Rails.application.config.respond_to?(:solid_queue)
      Rails.application.config.solid_queue.enabled = false
    end
  rescue NoMethodError, NameError
    # Ignorar silenciosamente si la configuración no está disponible
  end
end