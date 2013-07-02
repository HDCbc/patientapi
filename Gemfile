source :rubygems

gem 'sprockets'
gem 'coffee-script'
gem 'uglifier'
gem 'rake'
gem 'tilt'

group :test do
  gem 'minitest', '< 5.0.0'
  gem 'turn', :require => false

  platforms :ruby do
    gem 'libv8', '~> 3.11.8'
    #gem "libv8" 
    gem "therubyracer", :require => 'v8'
  end
  
  platforms :jruby do
    gem "therubyrhino"
  end
end