# Roda Basic Authentication

[![Build Status](https://travis-ci.org/badosu/roda-basic-auth.png)](https://travis-ci.org/badosu/roda-basic-auth)

Adds basic http authentication to Roda.

## Configuration

Configure your Roda application to use this plugin:

```ruby
plugin :basic_auth
```

You can pass global options, in this context they'll be shared between all
`r.basic_auth` calls.

```ruby
plugin :basic_auth, authenticator: proc {|user, pass| [user, pass] == %w[foo bar]},
                    realm: 'Restricted Area' # default
```

## Usage

Call `r.basic_auth` inside the routes you want to authenticate the user, it will halt
the request with 401 response code if the authenticator is false.

An additional `WWW-Authenticate` header is sent as specified on [rfc7235](https://tools.ietf.org/html/rfc7235#section-4.1) and it's realm can be configured.

You can specify the local authenticator with a block:

```ruby
r.basic_auth { |user, pass| [user, pass] == %w[foo bar] }
```

## Test

```sh
bundle exec ruby test/*.rb
```

## Warden

To avoid having your 401 responses intercepted by warden, you need to configure
the unauthenticated callback that is called just before the request is halted:

```ruby
plugin :basic_auth, unauthorized: proc {|r| r.env['warden'].custom_failure! }
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/badosu/roda-basic-auth.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
