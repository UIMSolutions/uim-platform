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
  return g.map!toString.array;
}
/// 
unittest {
  assert("authorization_code".toGrantType == GrantType.authorizationCode);
  assert("password".toGrantType == GrantType.password_);
  assert("refresh_token".toGrantType == GrantType.refreshToken);
  assert("implicit".toGrantType == GrantType.implicit_);
  assert("client_credentials".toGrantType == GrantType.clientCredentials);

  assert("".toGrantType == GrantType.clientCredentials);
  assert("unknown".toGrantType == GrantType.clientCredentials);
  
  assert(["authorization_code", "password", "refresh_token", "implicit", "client_credentials", "unknown"].toGrantTypes == [GrantType.authorizationCode, GrantType.password_, GrantType.refreshToken, GrantType.implicit_, GrantType.clientCredentials, GrantType.clientCredentials]);
  
  assert(GrantType.authorizationCode.toString == "authorization_code");
  assert(GrantType.password_.toString == "password");
  assert(GrantType.refreshToken.toString == "refresh_token");
  assert(GrantType.implicit_.toString == "implicit");
  assert(GrantType.clientCredentials.toString == "client_credentials");

  assert([GrantType.authorizationCode, GrantType.password_, GrantType.refreshToken, GrantType.implicit_, GrantType.clientCredentials].toStrings == ["authorization_code", "password", "refresh_token", "implicit", "client_credentials"]);
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
  return c.map!toString.array;
}
///
unittest {
  assert("confidential".toClientType == ClientType.confidential);
  assert("public".toClientType == ClientType.public_);

  assert("".toClientType == ClientType.confidential);
  assert("unknown".toClientType == ClientType.confidential);
  
  assert(["confidential", "public", "unknown"].toClientTypes == [ClientType.confidential, ClientType.public_, ClientType.confidential]);
  
  assert(ClientType.confidential.toString == "confidential");
  assert(ClientType.public_.toString == "public");

  assert([ClientType.confidential, ClientType.public_].toStrings == ["confidential", "public"]);
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
  return i.map!toString.array;
}
///
unittest {
  assert("saml2".toIdpType == IdpType.saml2);
  assert("oidc".toIdpType == IdpType.oidc);

  assert("".toIdpType == IdpType.saml2);
  assert("unknown".toIdpType == IdpType.saml2);
  
  assert(["saml2", "oidc", "unknown"].toIdpTypes == [IdpType.saml2, IdpType.oidc, IdpType.saml2]);
  
  assert(IdpType.saml2.toString == "saml2");
  assert(IdpType.oidc.toString == "oidc");

  assert([IdpType.saml2, IdpType.oidc].toStrings == ["saml2", "oidc"]);
}
