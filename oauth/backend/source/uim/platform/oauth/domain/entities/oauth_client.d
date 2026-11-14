/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.domain.entities.oauth_client;

import std.ascii : isAlphaNum;
import uim.platform.oauth;

mixin(ShowModule!());

@safe:

enum long minTokenValidity = 60; /// seconds
enum long maxAccessTokenValidity = 86_400; /// 1 day
enum long maxRefreshTokenValidity = 31_536_000; /// 1 year

/// A registered OAuth 2.0 client. The secret is stored as a salted SHA-256
/// hash only; the plain value is shown once (create / rotate).
struct OAuthClient {
  mixin TenantEntity!OAuthClientId;

  string clientId; /// public client identifier (RFC 6749 §2.2), unique per tenant
  string secretHash; /// hex SHA-256(salt ~ secret); "" for public clients
  string secretSalt;
  long secretRotatedAt;
  string name;
  string description;
  ClientType clientType = ClientType.confidential;
  ClientStatus status = ClientStatus.active;
  string[] redirectUris; /// exact match
  string[] allowedScopes;
  GrantType[] grantTypes = [GrantType.clientCredentials];
  long accessTokenValidity = 3600; /// seconds
  long refreshTokenValidity = 86_400; /// seconds
  string[] contacts; /// e-mail addresses of the owners
  string brandingId; /// optional BrandingConfig for the login page

  bool isActive() const {
    return status == ClientStatus.active;
  }

  bool isConfidential() const {
    return clientType == ClientType.confidential;
  }

  bool hasSecret() const {
    return secretHash.length > 0;
  }

  bool allowsGrant(GrantType grant) const {
    return grantTypes.canFind(grant);
  }

  bool allowsRedirect(string uri) const {
    return redirectUris.canFind(uri);
  }

  bool issuesRefreshTokens() const {
    return allowsGrant(GrantType.refreshToken);
  }

  void validate() const {
    requireText(name, "Client name");
    requireText(clientId, "Client ID");
    if (clientId.length > 128 || !clientId.all!(c => isAlphaNum(c) || c == '-' || c == '_' || c == '.' || c == '!' || c == '|'))
      throw OAuthException.invalid("Client ID may contain letters, digits and - _ . ! | (max. 128)");
    if (grantTypes.length == 0)
      throw OAuthException.invalid("At least one grant type is required");
    if (clientType == ClientType.public_ && allowsGrant(GrantType.clientCredentials))
      throw OAuthException.ruleViolation("Public clients cannot use the client_credentials grant");
    if (grantTypes == [GrantType.refreshToken])
      throw OAuthException.invalid("refresh_token needs authorization_code or client_credentials as well");
    if (allowsGrant(GrantType.authorizationCode) && redirectUris.length == 0)
      throw OAuthException.invalid("The authorization_code grant needs at least one redirect URI");
    foreach (uri; redirectUris) {
      auto problem = redirectUriProblem(uri);
      if (problem.length)
        throw OAuthException.invalid(problem);
    }
    foreach (s; allowedScopes)
      if (!isValidScopeName(s))
        throw OAuthException.invalid("Invalid scope name '" ~ s ~ "'");
    foreach (c; contacts)
      if (!c.canFind('@') || c.canFind(' '))
        throw OAuthException.invalid("Contact '" ~ c ~ "' is not an e-mail address");
    requireRange(accessTokenValidity, minTokenValidity, maxAccessTokenValidity, "accessTokenValidity");
    requireRange(refreshTokenValidity, minTokenValidity, maxRefreshTokenValidity, "refreshTokenValidity");
  }
}

///
unittest {
  OAuthClient c;
  c.name = "Billing";
  c.clientId = "sb-billing!t1";
  c.validate();
  assert(c.isActive && c.isConfidential && !c.issuesRefreshTokens);

  c.grantTypes = [GrantType.authorizationCode];
  assert(failsWith(OAuthErrorKind.invalid, () { c.validate(); })); // no redirect URI
  c.redirectUris = ["https://billing.example.com/callback"];
  c.validate();
  assert(c.allowsRedirect("https://billing.example.com/callback") && !c.allowsRedirect("https://billing.example.com/"));

  c.clientType = ClientType.public_;
  c.grantTypes ~= GrantType.clientCredentials;
  assert(failsWith(OAuthErrorKind.ruleViolation, () { c.validate(); }));
  c.grantTypes = [GrantType.authorizationCode];
  c.accessTokenValidity = 10;
  assert(failsWith(OAuthErrorKind.invalid, () { c.validate(); }));
}
