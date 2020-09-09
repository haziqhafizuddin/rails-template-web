#template.rb

def source_paths
  Array(super) +
    [File.join(File.expand_path(File.dirname(__FILE__)), '../templates')]
end

def setup_gemfile
  remove_file 'Gemfile'
  template 'Gemfile.erb', 'Gemfile'
  add_rails_version
  gem 'devise' if setup_devise?

  run 'bundle install'

  if setup_devise?
    generate 'devise:install'

    gsub_file(
      'config/initializers/devise.rb',
      'please-change-me-at-config-initializers-devise',
      'no-reply'
    )

    insert_into_file 'app/views/layouts/application.haml', after: "%body\n" do
<<-RUBY
  #flash
    - flash.each do |name, msg|
      = content_tag :div, msg,  :class => "alert alert-\#{name}"

RUBY
    end

    insert_into_file 'config/environments/development.rb', after: "Rails.application.configure do\n" do
<<-RUBY
  config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
RUBY
    end
  end
end

def setup_devise?
  return @setup_devise unless @setup_devise.nil?

  @setup_devise ||= yes?("Install Devise gem? [yes/no]")
end

def add_rails_version
  insert_into_file 'Gemfile', before: "# Use Postgresql as the database for Active Record" do
<<-RUBY
gem 'rails', '~> #{rails_version}'
RUBY
    end
end

def rails_version
  return '6.0.3' if ARGV[4].blank?
  version = ARGV[4].gsub(/[^0-9,.]/, "")
  return version unless version.to_i == 0
  '6.0.3'
end
# def generate_install
#   # TODO: devise install
# end

def replace_erb_with_haml
  remove_file 'app/views/layouts/application.html.erb'
  template 'application.haml', 'app/views/layouts/application.haml'
end

def insert_database_yml_example
  remove_file 'config/database.yml'
  template 'config/database.yml.erb', 'config/database.yml'
  template 'config/database.yml.erb', 'config/database.yml.example'
end

def configure_gitignore
  remove_file '.gitignore'
  copy_file 'gitignore.erb', '.gitignore'
end

replace_erb_with_haml
insert_database_yml_example
setup_gemfile
configure_gitignore

copy_file 'lib/tasks/qa.rake'

# spec config files
copy_file 'spec/support/factory_bot.rb'
copy_file 'spec/support/database_cleaner.rb'
copy_file 'spec/support/shoulda_matchers.rb'
copy_file 'spec/rails_helper.rb'
copy_file 'spec/spec_helper.rb'
copy_file '.rspec'
run "rm -rf test/"

# code analysis config files
copy_file 'config/config.reek'
copy_file '.rubocop.yml'
insert_into_file 'config/environments/development.rb', after: "Rails.application.configure do\n" do
<<-RUBY
  config.after_initialize do
    Bullet.enable = true
    Bullet.alert = true
    Bullet.bullet_logger = true
    Bullet.console = true
    Bullet.rails_logger = true
    Bullet.add_footer = true
  end
RUBY
end
run 'rails_best_practices -g'

def remove_comments_from(file_dir)
  gsub_file(file_dir, /^\s*#.*\n/, '')
end

rubocop_warned_files = %w[
  config/environments/test.rb
  config/environments/development.rb
  config/environments/production.rb
  config/application.rb
  config/routes.rb
  config/initializers/assets.rb
  config/initializers/backtrace_silencers.rb
  config/initializers/wrap_parameters.rb
  spec/rails_helper.rb
  spec/spec_helper.rb
  db/seeds.rb
  Rakefile
]

rubocop_warned_files << 'config/initializers/devise.rb' if setup_devise?

rubocop_warned_files.each do |offended_file|
  remove_comments_from(offended_file)
end
