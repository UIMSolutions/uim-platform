/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.domain.entities.application;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// Application (service provider / OAuth client) registered for SSO.
struct Application {
  mixin TenantEntity!ApplicationId;

  string name;
  string description;
  SsoProtocol protocol = SsoProtocol.oidc;
  string clientId;
  /// SHA-256 hash of the client secret. The plain secret is returned exactly
  /// once (on create / rotate) and never stored.
  string clientSecretHash;
  string[] redirectUris;
  string[] allowedScopes;
  string samlEntityId;
  string samlAcsUrl;
  string samlMetadataUrl;
  bool active = true;

  bool allowsScope(string scope_) const {
    return allowedScopes.length == 0 || allowedScopes.canFind(scope_);
  }

  bool allowsRedirect(string uri) const {
    return redirectUris.canFind(uri);
  }

  Json toJson() const {
    return entityToJson
      .set("name", name)
      .set("description", description)
      .set("protocol", enumValue(protocol))
      .set("clientId", clientId)
      .set("redirectUris", redirectUris.map!(s => Json(s)).array.toJson)
      .set("allowedScopes", allowedScopes.map!(s => Json(s)).array.toJson)
      .set("samlEntityId", samlEntityId)
      .set("samlAcsUrl", samlAcsUrl)
      .set("samlMetadataUrl", samlMetadataUrl)
      .set("active", active);
  }
}
