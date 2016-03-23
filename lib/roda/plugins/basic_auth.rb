require "roda"
require "roda/plugins/basic_auth/version"

module Roda::RodaPlugins
  module BasicAuth
    DEFAULTS = {
      realm: "Restricted Area",
      unauthorized_headers: proc do |opts|
        {'Content-Type' => 'text/plain',
         'Content-Length' => '0',
         'WWW-Authenticate' => ('Basic realm="%s"' % opts[:realm])}
      end,
      bad_request_headers: proc do |opts|
        {'Content-Type' => 'text/plain', 'Content-Length' => '0'}
      end
    }

    def self.configure(app, opts={})
      plugin_opts = (app.opts[:basic_auth] ||= DEFAULTS)
      app.opts[:basic_auth] = plugin_opts.merge(opts)
      app.opts[:basic_auth].freeze
    end

    module RequestMethods
      def basic_auth(opts={}, &authenticator)
        auth_opts = roda_class.opts[:basic_auth].merge(opts)
        authenticator ||= auth_opts[:authenticator]

        raise "Must provide an authenticator block" if authenticator.nil?

        auth = Rack::Auth::Basic::Request.new(env)

        unless auth.provided?
          auth_opts[:unauthorized].call(self) if auth_opts[:unauthorized]
          halt [401, auth_opts[:unauthorized_headers].call(auth_opts), []]
        end

        unless auth.basic?
          halt [400, auth_opts[:bad_request_headers].call(auth_opts), []]
        end

        if authenticator.call(*auth.credentials)
          env['REMOTE_USER'] = auth.username
        else
          auth_opts[:unauthorized].call(self) if auth_opts[:unauthorized]
          halt [401, auth_opts[:unauthorized_headers].call(auth_opts), []]
        end
      end
    end
  end

  register_plugin(:basic_auth, BasicAuth)
end
