source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.7.1"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.0.3", ">= 7.0.3.1"
# Use sqlite3 as the database for Active Record

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 5.0"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
# gem "jbuilder"

# Use Redis adapter to run Action Cable in production
# gem "redis", "~> 4.0"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem "image_processing", "~> 1.2"

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem "rack-cors"
gem "figaro"
gem 'devise'
gem 'omniauth-oktaoauth'
gem 'omniauth-google-oauth2'
gem 'omniauth-rails_csrf_protection'
gem 'rest-client'
gem "azure-storage-blob", require: false
gem 'capistrano', '~> 3.4'
gem 'capistrano-rbenv', '~> 2.2'
gem 'capistrano-passenger', '~> 0.2.1'
gem 'capistrano-rails', '~> 1.6', '>= 1.6.2'
gem 'capistrano-db-tasks', require: false
gem 'mini_portile2'
group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
end

group :development do
  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end


gem "jsonapi-serializer", "~> 2.2"

gem "pg", "~> 1.4"


group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem "sqlite3", "~> 1.4"
 
end
group :production do
  gem 'rails_12factor'
end




gem "addressable", "~> 2.8"
