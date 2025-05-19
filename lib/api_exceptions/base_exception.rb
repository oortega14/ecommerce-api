# ApiExceptions Folder
module ApiExceptions
  # Base Exception Class
  class BaseException < StandardError
    attr_reader :code, :messages, :type, :error_type

    def error_code_map
      {
        STANDARD_ERROR: { code: 1000, message: I18n.t('base_exceptions.standard_error') },
        RECORD_NOT_FOUND: { code: 1001, message: I18n.t('base_exceptions.record_not_found') },
        RECORD_NOT_UNIQUE: { code: 1002, message: I18n.t('base_exceptions.record_not_unique') },
        UNAUTHORIZED: { code: 1003, message: I18n.t('base_exceptions.unauthorized_user') },
        ADMIN_AUTHORIZATION: { code: 1004, message: I18n.t('base_exceptions.admin_authorization') },
        # Validaciones de usuario
        EMAIL_REQUIRED: { code: 1005, message: I18n.t('base_exceptions.email_required') },
        EMAIL_NOT_UNIQUE: { code: 1006, message: I18n.t('base_exceptions.email_not_unique') },
        PASSWORD_TOO_SHORT: { code: 1007, message: I18n.t('base_exceptions.password_too_short') },
        # Validaciones de productos
        CANNOT_PURCHASE: { code: 1008, message: I18n.t('base_exceptions.cannot_purchase') },
        # Validaciones de fechas
        INVALID_DATE_FORMAT: { code: 1009, message: I18n.t('base_exceptions.invalid_date_format') }
      }
    end

    def initialize(error_type, errors, params)
      super()
      error = error_code_map[error_type]
      @error_type = error_type
      @code = error[:code] if error
      error_messages = [ *errors ].flatten
      base_message = parse_message(error[:message], params) if error
      @messages = base_message ? [ base_message ] : []
      @messages += error_messages if error_messages.present?
      @messages = @messages.flatten.compact
      @type = 'Iswo'
    end

    def parse_message(message, params)
      @parsed_message = message.dup
      if params.present?
        params.each do |key, value|
          param = @parsed_message["{{#{parse_key(key)}}}"] || @parsed_message["%{#{parse_key(key)}}"]
          @parsed_message[param.to_s] = (value.to_s || 'nil') if param
        end
      end
      @parsed_message
    end

    def parse_key(key)
      if key.instance_of?(Integer)
        ''
      else
        key.try(:to_s)
      end
    end

    def get_code(error_type, code_base = 100)
      index = ERROR_CODES.find_index { |k, _| k == error_type }

      code_base + index
    end
  end
end
