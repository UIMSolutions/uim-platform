module domain.ports.token_service;

import domain.entities.user;
import domain.entities.application;
import domain.types;

/// Port: outgoing — token generation and validation.
interface TokenService
{
    /// Generate an access/id/refresh token.
    string generateToken(User user, Application app, TokenType tokenType, string[] scopes);

    /// Validate a token and return the user id, or null if invalid.
    string validateToken(string tokenValue);

    /// Generate a SAML assertion.
    string generateSamlAssertion(User user, Application app);
}
