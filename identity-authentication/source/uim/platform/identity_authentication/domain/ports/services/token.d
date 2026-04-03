/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.domain.ports.services.token;

// import uim.platform.identity_authentication.domain.entities.user;
// import uim.platform.identity_authentication.domain.entities.application;
// import uim.platform.identity_authentication.domain.types;
import uim.platform.identity_authentication;

mixin(ShowModule!());
@safe:
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
