# Configuración de FactoryBot para RSpec
require 'factory_bot'

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  # Eliminamos la carga explícita de definiciones para evitar duplicación
  # ya que ahora se cargan directamente en rails_helper.rb
  # config.before(:suite) do
  #   FactoryBot.find_definitions
  # end
end
