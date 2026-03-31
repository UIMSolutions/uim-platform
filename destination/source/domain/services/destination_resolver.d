module domain.services.destination_resolver;

import domain.entities.destination;
import domain.entities.destination_fragment;
import domain.entities.auth_token;
import domain.entities.destination_lookup;
import domain.types;

import std.datetime.systime : Clock;

/// Domain service: resolves a destination by merging fragments and generating auth tokens.
struct DestinationResolver
{
    /// Merge fragment properties into a destination configuration.
    static Destination applyFragments(Destination dest, const DestinationFragment[] fragments)
    {
        Destination result = dest;

        foreach (ref frag; fragments)
        {
            // Fragment overrides only non-empty fields
            if (frag.url.length > 0)
                result.url = frag.url;
            if (frag.authenticationType.length > 0)
                result.authenticationType = parseAuthType(frag.authenticationType);
            if (frag.proxyType.length > 0)
                result.proxyType = parseProxyType(frag.proxyType);
            if (frag.user.length > 0)
                result.user = frag.user;
            if (frag.password.length > 0)
                result.password = frag.password;
            if (frag.clientId.length > 0)
                result.clientId = frag.clientId;
            if (frag.clientSecret.length > 0)
                result.clientSecret = frag.clientSecret;
            if (frag.tokenServiceUrl.length > 0)
                result.tokenServiceUrl = frag.tokenServiceUrl;
            if (frag.locationId.length > 0)
                result.locationId = frag.locationId;
            if (frag.keystoreId.length > 0)
                result.keystoreId = frag.keystoreId;
            if (frag.truststoreId.length > 0)
                result.truststoreId = frag.truststoreId;

            // Merge custom properties
            foreach (k, v; frag.properties)
                result.properties[k] = v;
        }

        return result;
    }

    /// Generate a mock auth token based on the destination's authentication type.
    /// In production, this would call actual OAuth2 token endpoints or STS services.
    static AuthToken resolveAuthToken(const ref Destination dest)
    {
        AuthToken token;
        token.httpHeaderSuggestion = "Authorization";

        final switch (dest.authenticationType)
        {
            case AuthenticationType.noAuthentication:
                token.type_ = "";
                token.value_ = "";
                token.status = TokenStatus.valid;
                break;

            case AuthenticationType.basicAuthentication:
                import std.base64 : Base64;
                auto creds = cast(ubyte[])(dest.user ~ ":" ~ dest.password);
                token.type_ = "Basic";
                token.value_ = Base64.encode(creds);
                token.status = TokenStatus.valid;
                token.expiresAt = 0; // non-expiring
                break;

            case AuthenticationType.oauth2ClientCredentials:
            case AuthenticationType.oauth2SAMLBearerAssertion:
            case AuthenticationType.oauth2UserTokenExchange:
            case AuthenticationType.oauth2JWTBearer:
            case AuthenticationType.oauth2AuthorizationCode:
            case AuthenticationType.oauth2Password:
            case AuthenticationType.oauth2TechnicalUserPropagation:
            case AuthenticationType.oauth2MtlsClientCredentials:
                token.type_ = "Bearer";
                token.value_ = generateMockOAuthToken(dest);
                token.expiresAt = clockSeconds() + 3600;
                token.status = TokenStatus.valid;
                break;

            case AuthenticationType.clientCertificateAuthentication:
                token.type_ = "ClientCertificate";
                token.value_ = dest.keystoreId;
                token.httpHeaderSuggestion = "";
                token.status = TokenStatus.valid;
                break;

            case AuthenticationType.samlAssertion:
                token.type_ = "SAML";
                token.value_ = generateMockSAMLToken(dest);
                token.expiresAt = clockSeconds() + 1800;
                token.status = TokenStatus.valid;
                break;

            case AuthenticationType.principalPropagation:
                token.type_ = "PrincipalPropagation";
                token.value_ = "pp-token-placeholder";
                token.httpHeaderSuggestion = "SAP-Connectivity-Authentication";
                token.status = TokenStatus.valid;
                break;
        }

        return token;
    }

    private static string generateMockOAuthToken(const ref Destination dest)
    {
        import std.uuid : randomUUID;
        return "mock-oauth2-" ~ randomUUID().toString();
    }

    private static string generateMockSAMLToken(const ref Destination dest)
    {
        import std.uuid : randomUUID;
        return "mock-saml-" ~ randomUUID().toString();
    }

    static AuthenticationType parseAuthType(string s)
    {
        switch (s)
        {
            case "BasicAuthentication":                 return AuthenticationType.basicAuthentication;
            case "OAuth2ClientCredentials":             return AuthenticationType.oauth2ClientCredentials;
            case "OAuth2SAMLBearerAssertion":           return AuthenticationType.oauth2SAMLBearerAssertion;
            case "OAuth2UserTokenExchange":             return AuthenticationType.oauth2UserTokenExchange;
            case "OAuth2JWTBearer":                     return AuthenticationType.oauth2JWTBearer;
            case "OAuth2AuthorizationCode":             return AuthenticationType.oauth2AuthorizationCode;
            case "OAuth2Password":                      return AuthenticationType.oauth2Password;
            case "OAuth2TechnicalUserPropagation":      return AuthenticationType.oauth2TechnicalUserPropagation;
            case "OAuth2MtlsClientCredentials":         return AuthenticationType.oauth2MtlsClientCredentials;
            case "ClientCertificateAuthentication":     return AuthenticationType.clientCertificateAuthentication;
            case "SAMLAssertion":                       return AuthenticationType.samlAssertion;
            case "PrincipalPropagation":                return AuthenticationType.principalPropagation;
            default:                                    return AuthenticationType.noAuthentication;
        }
    }

    static ProxyType parseProxyType(string s)
    {
        switch (s)
        {
            case "OnPremise":   return ProxyType.onPremise;
            case "PrivateLink": return ProxyType.privateLink;
            default:            return ProxyType.internet;
        }
    }

    private static long clockSeconds()
    {
        return Clock.currTime().toUnixTime();
    }
}
