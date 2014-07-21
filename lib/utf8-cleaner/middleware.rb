module UTF8Cleaner
  class Middleware

    SANITIZE_ENV_KEYS = [
      "rack.input"
    ]

    def initialize(app)
     @app = app
    end

    def call(env)
      if valid_rack_input?(env)
        @app.call(env)
      else
        return [400, {'Content-Type' => 'text/html', 'Content-Length' => '11'}, ['Bad Request']]
      end
    end

    private

    def is_valid_utf8?(string)
      begin
        utf8 = string.dup.force_encoding('UTF-8')
        string == utf8 && utf8.valid_encoding?
      rescue EncodingError
        false
      end
    end

    def valid_rack_input?(env)
      is_valid_utf8?(env["rack.input"].read)
    end
  end
end
