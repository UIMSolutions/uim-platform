/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization_trust.domain.enumerations;

import uim.platform.authorization_trust;

// mixin(ShowModule!());

@safe:


// ---------------------------------------------------------------------------
// OAuth 2.0 grant types
// ---------------------------------------------------------------------------
enum GrantType {
  clientCredentials,
  authorizationCode,
  password_,
  refreshToken,
  implicit_,
}
// ---------------------------------------------------------------------------
// OAuth 2.0 client types
// ---------------------------------------------------------------------------
enum ClientType {
  confidential,
  public_,
}
// ---------------------------------------------------------------------------
// Identity provider protocol types
// ---------------------------------------------------------------------------
enum IdpType {
  saml2,
  oidc,
}
IdpType toIdpType(string s) @safe {
  import std.uni : toLower;
  return (s.toLower == "oidc") ? IdpType.oidc : IdpType.saml2;
}
// ---------------------------------------------------------------------------
// Helpers — GrantType
// ---------------------------------------------------------------------------
GrantType toGrantType(string s) @safe {
  import std.uni : toLower;
  switch (s.toLower) {
    case "authorization_code": return GrantType.authorizationCode;
    case "password":           return GrantType.password_;
    case "refresh_token":      return GrantType.refreshToken;
    case "implicit":           return GrantType.implicit_;
    default:                   return GrantType.clientCredentials;
  }
}

string toString(GrantType g) @safe {
  final switch (g) {
    case GrantType.clientCredentials: return "client_credentials";
    case GrantType.authorizationCode: return "authorization_code";
    case GrantType.password_:         return "password";
    case GrantType.refreshToken:      return "refresh_token";
    case GrantType.implicit_:         return "implicit";
  }
}
// ---------------------------------------------------------------------------
// Helpers — ClientType
// ---------------------------------------------------------------------------
ClientType toClientType(string s) @safe {
  import std.uni : toLower;
  return (s.toLower == "public") ? ClientType.public_ : ClientType.confidential;
}

string toString(ClientType c) @safe {
  final switch (c) {
    case ClientType.confidential: return "confidential";
    case ClientType.public_:      return "public";
  }
}
