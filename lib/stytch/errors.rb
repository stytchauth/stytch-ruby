module Stytch
    class JWTInvalidIssuerError < StandardError
        def initialize(msg="JWT issuer did not match")
            super
        end
    end

    class JWTInvalidAudienceError < StandardError
        def initialize(msg="JWT audience did not match")
            super
        end
    end

    class JWTExpiredSignatureError < StandardError
        def initialize(msg="JWT signature has expired")
            super
        end
    end

    class JWTIncorrectAlgorithmError < StandardError
        def initialize(msg="JWT algorithm is incorrect")
            super
        end
    end
end
