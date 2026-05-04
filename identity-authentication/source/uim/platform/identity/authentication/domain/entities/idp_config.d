/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.domain.entities.idp_config;

// import uim.platform.identity_authentication.domain.types;

import uim.platform.identity_authentication;

mixin(ShowModule!());
@safe:
/// External Identity Provider configuration for delegated authentication.
struct IdpConfig {
  mixin TenantEntity!IdpConfigId;

  string name;
  IdpType idpType;
  string metadataUrl;
  string authorizationEndpoint;
  string tokenEndpoint;
  string userInfoEndpoint;
  string clientId;
  string clientSecret;
  string[] domainHints; // email domains that route to this IdP
  bool isDefault;
  bool active = true;
  
  Json toJson() const {
    return entityToJson
      .set("name", name)
      .set("idpType", idpType.to!string)
      .set("metadataUrl", metadataUrl)
      .set("authorizationEndpoint", authorizationEndpoint)
      .set("tokenEndpoint", tokenEndpoint)
      .set("userInfoEndpoint", userInfoEndpoint)
      .set("clientId", clientId)
      .set("domainHints", domainHints)
      .set("isDefault", isDefault)
      .set("active", active);
  }
}
