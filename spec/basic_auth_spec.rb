require File.expand_path("spec_helper", File.dirname(__FILE__))

describe 'Roda::RodaPlugins::BasicAuth' do
  describe 'when global authenticator is configured' do
    before do
      roda do |r|
        r.plugin :basic_auth, authenticator: ->(u, p) { [u, p] == %w[foo bar] }
      end
    end

    describe 'and local authenticator is set' do
      before do
        app_root { |u, p| [u, p] == %w[baz inga] }

        basic_authorize(*credentials)

        get '/'
      end

      describe 'and new authenticator matches' do
        let(:credentials) { %w[baz inga] }

        it 'is authorized' do
          assert_authorized
        end
      end

      describe 'and new authenticator does not match' do
        let(:credentials) { %w[foo bar] }

        it 'is unauthorized' do
          assert_unauthorized
        end
      end
    end

    describe 'when no local authenticator is set' do
      before { app_root }

      describe 'and no credentials are passed' do
        before { get '/' }

        it('is unauthorized') { assert_unauthorized }
      end

      describe 'and credentials are passed' do
        before do
          basic_authorize(*credentials)

          get '/'
        end

        describe 'and they match the global authenticator' do
          let(:credentials) { %w[foo bar] }

          it('is authorized') { assert_authorized }
        end

        describe 'and they do not match the global authenticator' do
          let(:credentials) { %w[foo baz] }

          it('is unauthorized') { assert_unauthorized }
        end
      end
    end
  end

  describe 'when no global authenticator is configured' do
    before { roda { |r| r.plugin :basic_auth } }

    describe 'and local authenticator is configured' do
      before do
        app_root { |u, p| [u, p] == %w[baz inga] }

        basic_authorize(*credentials)

        get '/'
      end

      describe 'and local authenticator matches' do
        let(:credentials) { %w[baz inga] }

        it('is authorized') { assert_authorized }
      end

      describe 'and local authenticator does not match' do
        let(:credentials) { %w[foo bar] }

        it('is unauthorized') { assert_unauthorized }
      end
    end

    describe 'and no local authenticator is configured' do
      it 'raises an error' do
        app_root

        exception = assert_raises(RuntimeError) { get '/' }

        assert_equal("Must provide an authenticator block", exception.message)
      end
    end
  end

  describe 'when realm is configured globally' do
    before { roda { |r| r.plugin :basic_auth, realm: "NetherRealm" } }

    it 'is sent on WWW-Authenticate on unauthorization' do
      app_root { |u, p| [u, p] == %w[baz inga] }

      get '/'

      assert_unauthorized

      assert_equal("Basic realm=\"NetherRealm\"",
                   last_response['WWW-Authenticate'])
    end
  end

  describe 'when realm is configured locally' do
    before { roda { |r| r.plugin :basic_auth } }

    it 'is sent on WWW-Authenticate on unauthorization' do
      app_root(realm: "NoetherRealm") { |u, p| [u, p] == %w[baz inga] }

      get '/'

      assert_unauthorized(realm: "NoetherRealm")
    end
  end

  describe 'when realm is not configured' do
    before { roda { |r| r.plugin :basic_auth } }

    it 'sends "Restricted Area" on WWW-Authenticate on unauthorization' do
      app_root { |u, p| [u, p] == %w[baz inga] }

      get '/'

      assert_unauthorized

      assert_equal('Basic realm="Restricted Area"',
                   last_response['WWW-Authenticate'])
    end
  end
end
