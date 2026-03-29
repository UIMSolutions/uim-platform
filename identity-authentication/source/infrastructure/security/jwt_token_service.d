module uim.platform.identity_authentication.infrastructure.security.jwt_token_service;

import domain.entities.user;
import domain.entities.application;
import domain.types;
import domain.ports.token_service;

import std.uuid;
import std.conv : to;
import std.datetime.systime : Clock;
import core.time;
import std.digest.sha : SHA256, toHexString;

/// Adapter: JWT-like token generation service.
/// In production, use proper JWT signing with RS256/ES256.
class JwtTokenService : TokenService
{
    private string signingSecret;

    this(string signingSecret)
    {
        this.signingSecret = signingSecret;
    }

    string generateToken(User user, Application app, TokenType tokenType, string[] scopes)
    {
        import std.array : join;

        auto now = Clock.currStdTime();
        auto payload = user.id ~ "|" ~ app.id ~ "|" ~ tokenType.to!string
            ~ "|" ~ scopes.join(",") ~ "|" ~ now.to!string;

        // Sign payload
        auto signature = sign(payload);
        return payload ~ "." ~ signature;
    }

    string validateToken(string tokenValue)
    {
        import std.string : lastIndexOf, split;

        auto dotIdx = tokenValue.lastIndexOf('.');
        if (dotIdx < 0)
            return null;

        auto payload = tokenValue[0 .. dotIdx];
        auto signature = tokenValue[dotIdx + 1 .. $];

        if (sign(payload) != signature)
            return null;

        // Extract user ID from payload
        auto parts = payload.split("|");
        if (parts.length < 1)
            return null;

        return parts[0]; // userId
    }

    string generateSamlAssertion(User user, Application app)
    {
        // Simplified SAML assertion (in production, use proper XML signing)
        return "<saml:Assertion>"
            ~ "<saml:Issuer>identity-authentication</saml:Issuer>"
            ~ "<saml:Subject><saml:NameID>" ~ user.email ~ "</saml:NameID></saml:Subject>"
            ~ "<saml:Conditions><saml:AudienceRestriction>"
            ~ "<saml:Audience>" ~ app.samlEntityId ~ "</saml:Audience>"
            ~ "</saml:AudienceRestriction></saml:Conditions>"
            ~ "</saml:Assertion>";
    }

    private string sign(string data)
    {
        SHA256 hasher;
        hasher.start();
        hasher.put(cast(const(ubyte)[])(data ~ signingSecret));
        auto digest = hasher.finish();
        return toHexString(digest).idup;
    }
}
