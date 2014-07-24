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
    def valid_rack_input?(env)
      io = env["rack.input"]
      is_valid = true
      if io && env["CONTENT_TYPE"] == 'application/x-www-form-urlencoded'
        is_valid = is_valid_utf8?(io.read)
        io.rewind
        env["rack.input"] = StringIO.new(io.read)
      else
        # do nothing
      end
      is_valid
    end

    def is_valid_utf8?(string)
      begin
        utf8 = string.dup.force_encoding('UTF-8')
        string == utf8 && utf8.valid_encoding?
      rescue EncodingError
        false
      end
    end

  end
end
