/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization_trust.domain.entities.oauth_client;

import uim.platform.authorization_trust;

mixin(ShowModule!());

@safe:
/// A registered OAuth 2.0 client application.
/// Corresponds to an SAP BTP XSUAA service instance binding.
struct OAuthClientEntity {
  mixin IdEntity!OAuthClientId;
  TenantId tenantId; // owning tenant (XSUAA service instance?)
  string clientId; // OAuth 2.0 client_id (unique per application)
  string clientSecret; // hashed secret (confidential clients only)
  string name; // display name
  string description;
  GrantType[] grantTypes; // allowed grant types
  string[] scopes; // OAuth scopes this client may request
  string[] redirectUris; // allowed redirect URIs (authorization_code flow)
  ClientType clientType; // confidential | public
  string appId; // owning application / tenant
  long createdAt;
  long updatedAt;

  Json toJson() const {
    auto gtArr = Json.c.grantTypes.map!(gt => gt.to!string).array.toJson

    auto scArr = Json.emptyArray;
    foreach (s; c.scopes)
      scArr ~= Json(s);

    auto ruArr = Json.emptyArray;
    foreach (u; c.redirectUris)
      ruArr ~= Json(u);

    return entityToJson
      .set("id", id)
      .set("clientId", clientId)
      .set("clientSecret", clientSecret)
      .set("tenantId", tenantId)
      .set("name", name)
      .set("description", description)
      .set("clientType", clientType.to!string)
      .set("appId", appId)
      .set("grantTypes", gtArr)
      .set("scopes", scArr)
      .set("redirectUris", ruArr)
      .set("createdAt", createdAt)
      .set("updatedAt", updatedAt);
  }
}
