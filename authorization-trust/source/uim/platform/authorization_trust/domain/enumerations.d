/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization_trust.domain.enumerations;

import uim.platform.authorization_trust;

mixin(ShowModule!());

@safe:

// ---------------------------------------------------------------------------
// OAuth 2.0 grant types
// ---------------------------------------------------------------------------
enum GrantType : string {
  clientCredentials = "client_credentials",
  authorizationCode = "authorization_code",
  password_ = "password",
  refreshToken = "refresh_token",
  implicit_ = "implicit",
}

GrantType toGrantType(string s) @safe {
  import std.uni : toLower;

  switch (s.toLower) {
  case "authorization_code":
    return GrantType.authorizationCode;
  case "password":
    return GrantType.password_;
  case "refresh_token":
    return GrantType.refreshToken;
  case "implicit":
    return GrantType.implicit_;
  default:
    return GrantType.clientCredentials;
  }
}

GrantType[] toGrantTypes(string[] s) @safe {
  return s.map!(toGrantType).array;
}

string toString(GrantType g) @safe {
  return cast(string)g;
}

string[] toStrings(GrantType[] g) @safe {
  return g.map!(toString).array;
}
/// 
unittest {
  assert(toGrantType("authorization_code") == GrantType.authorizationCode);
  assert(toGrantType("password") == GrantType.password_);
  assert(toGrantType("refresh_token") == GrantType.refreshToken);
  assert(toGrantType("implicit") == GrantType.implicit_);
  assert(toGrantType("client_credentials") == GrantType.clientCredentials);

  assert(toGrantType("") == GrantType.clientCredentials);
  assert(toGrantType("unknown") == GrantType.clientCredentials);
  
  assert(toGrantTypes(["authorization_code", "password", "refresh_token", "implicit", "client_credentials", "unknown"]) == [GrantType.authorizationCode, GrantType.password_, GrantType.refreshToken, GrantType.implicit_, GrantType.clientCredentials, GrantType.clientCredentials]);
  
  assert(toString(GrantType.authorizationCode) == "authorization_code");
  assert(toString(GrantType.password_) == "password");
  assert(toString(GrantType.refreshToken) == "refresh_token");
  assert(toString(GrantType.implicit_) == "implicit");
  assert(toString(GrantType.clientCredentials) == "client_credentials");
  assert(toString([GrantType.authorizationCode, GrantType.password_, GrantType.refreshToken, GrantType.implicit_, GrantType.clientCredentials]) == ["authorization_code", "password", "refresh_token", "implicit", "client_credentials"]);
}
// ---------------------------------------------------------------------------
// OAuth 2.0 client types
// ---------------------------------------------------------------------------
enum ClientType {
  confidential,
  public_,
}
ClientType toClientType(string s) @safe {
  import std.uni : toLower;

  return (s.toLower == "public") ? ClientType.public_ : ClientType.confidential;
}
ClientType[] toClientTypes(string[] s) @safe {
  return s.map!(toClientType).array;
}
string toString(ClientType c) @safe {
  return (c == ClientType.confidential) ? "confidential" : "public";
}
string[] toStrings(ClientType[] c) @safe {
  return c.map!(toString).array;
}
///
unittest {
  assert(toClientType("confidential") == ClientType.confidential);
  assert(toClientType("public") == ClientType.public_);

  assert(toClientType("") == ClientType.confidential);
  assert(toClientType("unknown") == ClientType.confidential);
  
  assert(toClientTypes(["confidential", "public", "unknown"]) == [ClientType.confidential, ClientType.public_, ClientType.confidential]);
  
  assert(toString(ClientType.confidential) == "confidential");
  assert(toString(ClientType.public_) == "public");

  assert(toString([ClientType.confidential, ClientType.public_]) == ["confidential", "public"]);
}
// ---------------------------------------------------------------------------
// Identity provider protocol types
// ---------------------------------------------------------------------------
enum IdpType {
  saml2,
  oidc,
}
IdpType toIdpType(string value) @safe {
  mixin(EnumSwitch("IdpType", "saml2"));
}
IdpType[] toIdpTypes(string[] s) @safe {
  return s.map!(toIdpType).array;
}
string toString(IdpType type) @safe {
  return type.to!string;
}
string[] toStrings(IdpType[] i) @safe {
  return i.map!(toString).array;
}
///
unittest {
  assert(toIdpType("saml2") == IdpType.saml2);
  assert(toIdpType("oidc") == IdpType.oidc);

  assert(toIdpType("") == IdpType.saml2);
  assert(toIdpType("unknown") == IdpType.saml2);
  
  assert(toIdpTypes(["saml2", "oidc", "unknown"]) == [IdpType.saml2, IdpType.oidc, IdpType.saml2]);
  
  assert(toString(IdpType.saml2) == "saml2");
  assert(toString(IdpType.oidc) == "oidc");

  assert(toString([IdpType.saml2, IdpType.oidc]) == ["saml2", "oidc"]);
}
