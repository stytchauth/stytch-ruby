module Stytch
  class JWTInvalidIssuerError < StandardError
    def initialize(msg = 'JWT issuer did not match')
      super
    end
  end

  class JWTInvalidAudienceError < StandardError
    def initialize(msg = 'JWT audience did not match')
      super
    end
  end

  class JWTExpiredSignatureError < StandardError
    def initialize(msg = 'JWT signature has expired')
      super
    end
  end

  class JWTIncorrectAlgorithmError < StandardError
    def initialize(msg = 'JWT algorithm is incorrect')
      super
    end
  end

  class JWTExpiredError < StandardError
    def initialize(msg = 'JWT has expired')
      super
    end
  end

  class TokenMissingScopeError < StandardError
    def initialize(scope)
      msg = "Missing required scope #{scope}"
      super(msg)
    end
  end

  class TenancyError < StandardError
    def initialize(subject_org_id, request_org_id)
      msg = "Subject organization_id #{subject_org_id} does not match authZ request organization_id #{request_org_id}"
      super(msg)
    end
  end

  class PermissionError < StandardError
    def initialize(request)
      msg = "Permission denied for request #{request}"
      super(msg)
    end
  end

  class M2MPermissionError < StandardError
    def initialize(has_scopes, required_scopes)
      msg = "Missing at least one required scope from #{required_scopes} for M2M request with scopes #{has_scopes}"
      super(msg)
    end
  end
end
