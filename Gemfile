source 'https://rubygems.org'
ruby '2.5.1'

# Web API
gem 'puma'
gem 'roda'
gem 'json'

# Configuration
gem 'econfig'
gem 'rake'

# Diagnostic
gem 'pry'
gem 'rack-test'

# Security
gem 'rbnacl-libsodium'

# Database
gem 'sequel'
gem 'hirb'

group :development, :test do
  gem 'sequel-seed'
  gem 'sqlite3'
end

# production
group :production do
  gem 'pg'
end

# Testing
group :test do
  gem 'minitest'
  gem 'minitest-rg'
end

# Development
group :development do
  gem 'rubocop'
end

group :development, :test do
  gem 'rerun'
end
