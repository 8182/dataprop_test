require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module DatapropTest
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Desactivar Action Cable completamente
    config.action_cable.mount_path = nil
    config.action_cable.url = nil
    config.action_cable.allowed_request_origins = nil
    config.action_cable.disable_request_forgery_protection = true

    config.cache_store = :memory_store

    config.autoload_lib(ignore: %w[assets tasks])

  end
end