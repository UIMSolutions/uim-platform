/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization_trust.domain.types;
// ---------------------------------------------------------------------------
// ID type aliases
// ---------------------------------------------------------------------------
alias OAuthClientId      = string;
alias ScopeId            = string;
alias RoleId             = string;
alias RoleCollectionId   = string;
alias UserAssignmentId   = string;
alias IdentityProviderId = string;
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
// ---------------------------------------------------------------------------
// Helpers — GrantType
// ---------------------------------------------------------------------------
GrantType parseGrantType(string s) @safe {
  import std.uni : toLower;
  switch (s.toLower) {
    case "authorization_code": return GrantType.authorizationCode;
    case "password":           return GrantType.password_;
    case "refresh_token":      return GrantType.refreshToken;
    case "implicit":           return GrantType.implicit_;
    default:                   return GrantType.clientCredentials;
  }
}

string grantTypeToString(GrantType g) @safe {
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
ClientType parseClientType(string s) @safe {
  import std.uni : toLower;
  return (s.toLower == "public") ? ClientType.public_ : ClientType.confidential;
}

string clientTypeToString(ClientType c) @safe {
  final switch (c) {
    case ClientType.confidential: return "confidential";
    case ClientType.public_:      return "public";
  }
}
// ---------------------------------------------------------------------------
// Helpers — IdpType
// ---------------------------------------------------------------------------
IdpType parseIdpType(string s) @safe {
  import std.uni : toLower;
  return (s.toLower == "oidc") ? IdpType.oidc : IdpType.saml2;
}

string idpTypeToString(IdpType t) @safe {
  final switch (t) {
    case IdpType.saml2: return "saml2";
    case IdpType.oidc:  return "oidc";
  }
}
