Project generated with this template will be installed with additional gems and configurations as follow:

### Gems included:
- [x] pg
- [x] Rspec
- [x] Capybara
- [x] Factory Bot
- [x] HAML
- [x] Reek, Rails best practice and Rubocop (for code_analysis)
- [x] Database cleaner
- [x] pry
- [x] puma
- [x] bullet
- [x] zero_downtime_migrations
- [x] Devise (optional)

### Usage:

    # using rails version installed in your machine (version 6 or above)
    $ rails new yourprojectname -m ~/dir_to_this_repo/lib/template.rb

    # using specific rails version
    $ rails new yourprojectname -m ~/dir_to_this_repo/lib/template.rb 6.0.3
    # default rails verions is 6.0.3

note: Please make sure local rails gem is version 5 or above
note: Backward compatibility of rails 4 is not supported. Checkout the previous commit for rails 4 compatibility


Setup ```database.yml```

    $ cp config/database.yml.example config/database.yml

Key in your ```username``` and ```password``` for postgres db at ```config/database.yml``` that you just cloned.

Next:

    $ rails db:setup; rails db:migrate

### Test

    $ rails qa # run all tests before creating pull requests

Individual test:

    $ rails qa:rubocop
    $ rails qa:reek
    $ rails qa:rbp
    $ rspec
