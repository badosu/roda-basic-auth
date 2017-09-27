require File.expand_path("spec_helper", File.dirname(__FILE__))

describe 'Roda::RodaPlugins::BasicAuth' do
  describe 'When global authenticator is configured' do
    before do
      roda do |r|
        r.plugin :basic_auth, authenticator: ->(u, p) { [u, p] == %w[foo bar] }
      end
    end

    describe 'when local authenticator is set' do
      before { app_root { |u, p| [u, p] == %w[baz inga] } }

      it 'overrides the global succeeding' do
        basic_authorize 'baz', 'inga'

        get '/'

        assert_authorized
      end

      it 'overrides the global failing' do
        basic_authorize 'foo', 'bar'

        get '/'

        assert_unauthorized
      end
    end

    describe 'when no local authenticator is set' do
      before { app_root }

      describe 'when authenticator passes' do
        before { basic_authorize 'foo', 'bar' }

        it 'serves the content' do
          get '/'

          assert_authorized
        end
      end

      describe 'when authenticator fails' do
        before { basic_authorize 'foo', 'baz' }

        it 'is unauthorized' do
          get '/'

          assert_unauthorized
        end
      end

      describe 'when no credentials are passed' do
        it 'is unauthorized' do
          get '/'

          assert_unauthorized
        end
      end
    end
  end

  describe 'When no global authenticator is configured' do
    before do
      roda { |r| r.plugin :basic_auth }
    end

    describe 'when local authenticator is set' do
      before { app_root { |u, p| [u, p] == %w[baz inga] } }

      it 'authorizes when the authenticator passes' do
        basic_authorize 'baz', 'inga'

        get '/'

        assert_authorized
      end

      it 'unauthorizes when the authenticator fails' do
        basic_authorize 'foo', 'bar'

        get '/'

        assert_unauthorized
      end
    end

    describe 'when no local authenticator is set' do
      it 'raises an error' do
        app_root

        exception = assert_raises(RuntimeError) { get '/' }
        assert_equal( "Must provide an authenticator block", exception.message )
      end
    end
  end
end
