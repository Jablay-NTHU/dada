require 'roda'
require 'econfig'
# …
class ShareConfigurationsAPI < Roda::Base
	extend Econfig::Shortcut
		
		configure do
			Econfig.env = settings.environment.to_s
			Econfig.root = File.expand_path('..', settings.root)
			
			SecureDB.setup(settings.config)
	end