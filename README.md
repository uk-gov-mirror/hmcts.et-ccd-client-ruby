# EtCcdClient

The ET CCD Client is a ruby interface to the CCD API and the CCD UI API specifically for employment
tribunals.

Note that this is general purpose CCD stuff, but this gem cannot claim to be a full CCD client
as it only has methods specific to employment tribunal.

In general, the EtApiClient::Client is used for the main CCD API where the secret is known and the
EtApiClient::UiClient is used to access the UI (front end) API where a username and password is known (generally
 in a test environment)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'et_ccd_client'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install et_ccd_client

## Usage (Main CCD API)

```

client = EtApiClient::Client.new
client.login

client.caseworker_search_latest_by_reference('222000000100', case_type_id: 'EmpTrib_MVP_1.0_Manc')

```

## Usage (UI API)

```
client = EtApiClient::UiClient.new
client.login

client.search_latest_by_reference('222000000100', case_type_id: 'EmpTrib_MVP_1.0_Manc')

```
## Configuration

To configure the client, use a block like this :-

```
EtCcdClient.config do |c|
    c.auth_base_url = <value>
    c.idam_base_url = <value>
    c.data_store_base_url = <value>
    c.jurisdiction_id = <value>
    c.microservice = <value>
    c.microservice_secret = <value>
    c.idam_ui_base_url = <value> (Only needed if using UI API)
    c.idam_ui_redirect_url = <value> (Only needed if using UI API)
    c.use_sidam = <value> (If true uses sidam - else tidam)
    c.sidam_username = <value> (Only needed if use_sidam is true)
    c.sidam_password = value (Only needed if use_sidam is true)
    c.user_id = <value> (Only needed if use_sidam is false)
    c.user_role = <value> (Only needed if use_sidam is false)
    c.pool_size = <value> The size of the connection pool (do not set lower than number of sidekiq threads)
    c.pool_timeout = <value) The time in seconds where we give up waiting for someone to release a client to the pool
    c.logger = Rails.logger (or any instance of an active support logger if you dont have rails)
end

```

If you don't set any of these, the defaults should work with local ccd-docker

If you don't set the logger, no logging output will be sent.
If you share your rails logger or configure a new one, only debug output is set generally.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hmcts/et_ccd_client.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
