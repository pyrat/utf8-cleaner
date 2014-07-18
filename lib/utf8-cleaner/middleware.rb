module UTF8Cleaner
  class Middleware

    SANITIZE_ENV_KEYS = [
     "HTTP_REFERER",
     "PATH_INFO",
     "QUERY_STRING",
     "REQUEST_PATH",
     "REQUEST_URI",
     "rack.request.form_vars"
    ]

    def initialize(app)
     @app = app
    end

    def call(env)
      if valid_env?(env)
        @app.call(env)
      else
        return [400, {'Content-Type' => 'text/html', 'Content-Length' => '11'}, ['Bad Request']]
      end
    end

    private

    def is_valid_utf8(string)
      utf8 = string.dup.force_encoding('UTF-8')
      string == utf8 && utf8.valid_encoding?
    rescue EncodingError
      false
    end

    def sanitize_env(env)
      SANITIZE_ENV_KEYS.each do |key|
        next unless value = env[key]

        env[key] = URIString.new(value).cleaned
      end
      env
    end

    def valid_env?(env)
      SANITIZE_ENV_KEYS.all? do |key|
        if value = env[key]
          URIString.new(value).valid?
        else
          true
        end
      end
    end
  end
end
