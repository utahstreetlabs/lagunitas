source :rubygems

#gem 'dino', '>= 1.0.0'
gem 'dino', :path => '../dino'
gem 'unicorn'
gem 'mongoid'
gem 'bson_ext'
gem 'json_patch', '>= 0.1.2'
#gem 'json_patch', path: '../json_patch'
gem 'progress_bar'
gem 'log_weasel', path: '../log_weasel'

group :development, :test do
  gem 'rspec'
  gem 'factory_girl'
  gem 'mocha'
  gem 'rack-test'
  gem 'rake'
  gem 'foreman'
end

group :development do
  gem 'capistrano'
  gem 'capistrano-ext'
  gem 'hipchat'
  gem 'thor'
  if ENV['LAGUNITAS_DEBUG']
    gem 'ruby-debug19'
    gem 'ruby-debug-base19'
  end
end
