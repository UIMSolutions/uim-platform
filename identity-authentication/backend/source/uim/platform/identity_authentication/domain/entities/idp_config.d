/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.domain.entities.idp_config;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// Corporate / external identity provider for delegated authentication.
struct IdpConfig {
  mixin TenantEntity!IdpConfigId;

  string name;
  IdpType idpType = IdpType.oidc;
  string metadataUrl;
  string authorizationEndpoint;
  string tokenEndpoint;
  string userInfoEndpoint;
  string clientId;
  /// Never serialized to clients.
  string clientSecret;
  /// E-mail domains that are routed to this IdP (e.g. "example.com").
  string[] domainHints;
  bool isDefault;
  bool active = true;

  bool handlesDomain(string emailDomain) const {
    return domainHints.any!(d => sicmp(d, emailDomain) == 0);
  }

  Json toJson() const {
    return entityToJson
      .set("name", name)
      .set("idpType", enumValue(idpType))
      .set("metadataUrl", metadataUrl)
      .set("authorizationEndpoint", authorizationEndpoint)
      .set("tokenEndpoint", tokenEndpoint)
      .set("userInfoEndpoint", userInfoEndpoint)
      .set("clientId", clientId)
      .set("domainHints", domainHints.map!(s => Json(s)).array.toJson)
      .set("isDefault", isDefault)
      .set("active", active);
  }
}
