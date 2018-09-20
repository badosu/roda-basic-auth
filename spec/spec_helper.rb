$: << 'lib'

require 'minitest/autorun'
require 'roda'

require 'rack/test'

class Minitest::Spec
  include Rack::Test::Methods

  attr_accessor :app

  def app_root(*opts, &block)
    app.route do |r|
      r.root do
        r.basic_auth(*opts, &block)

        "I am ROOT!"
      end
    end
  end

  def roda
    app = Class.new(Roda)

    yield app

    self.app = app
  end

  def assert_authorized
    assert_equal 200, last_response.status
    assert_equal "I am ROOT!", last_response.body
  end

  def assert_unauthorized(realm: app.opts[:basic_auth][:realm])
    assert_equal 401, last_response.status
    assert_equal "Basic realm=\"#{realm}\"", last_response['WWW-Authenticate']
  end
end
