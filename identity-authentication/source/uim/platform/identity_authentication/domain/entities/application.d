/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.domain.entities.application;

// import uim.platform.identity_authentication.domain.types;
import uim.platform.identity_authentication;

mixin(ShowModule!());
@safe:
/// Application (Service Provider) registered for SSO.
struct Application
{
  ApplicationId id;
  TenantId tenantId;
  string name;
  string description;
  SsoProtocol protocol = SsoProtocol.oidc;
  string clientId;
  string clientSecret;
  string[] redirectUris;
  string[] allowedScopes;
  string samlEntityId;
  string samlAcsUrl;
  string samlMetadataUrl;
  bool active = true;
  long createdAt;
  long updatedAt;

  Json toJson()
  {
    return Json.emptyObject.set("id", id).set("tenantId", tenantId).set("name",
        name).set("description", description).set("protocol", to!string(protocol))
      .set("clientId", clientId).set("redirectUris", redirectUris).set("allowedScopes", allowedScopes)
      .set("samlEntityId", samlEntityId).set("samlAcsUrl", samlAcsUrl).set("samlMetadataUrl",
        samlMetadataUrl).set("active", active).set("createdAt", createdAt)
      .set("updatedAt", updatedAt);
  }
}
