/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.directory.domain.entities.api_client;

// import uim.platform.identity.directory.domain.types;
import uim.platform.identity.directory;

mixin(ShowModule!());

@safe:
/// API client / technical user for service-to-service access.
struct ApiClient {
  ApiClientId id;
  TenantId tenantId;
  string name;
  string description;
  string clientId;
  string clientSecret;
  string[] scopes;
  bool active = true;
  long createdAt;
  long expiresAt; // 0 = no expiry
  long lastUsedAt;

  bool isExpired(long now) const
  {
    return expiresAt > 0 && now > expiresAt;
  }
}
