/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_directory.infrastructure.persistence.repositories.api_clients;
// import uim.platform.identity_directory.domain.entities.api_client;

// import uim.platform.identity_directory.domain.ports.repositories.api_clients;
import uim.platform.identity_directory;

mixin(ShowModule!());

@safe:
/// In-memory adapter for API client persistence.
class MemoryApiClientRepository : TenantRepository!(ApiClient, ApiClientId), ApiClientRepository {
  bool existsByClient(TenantId tenantId, string clientId) {
    return findByTenant(tenantId).any!(c => c.clientId == clientId);
  }

  ApiClient findByClient(TenantId tenantId, string clientId) {
    foreach (c; findByTenant(tenantId)) {
      if (c.clientId == clientId)
        return c;
    }
    return ApiClient.init;
  }

  void removeByClient(TenantId tenantId, string clientId) {
    auto client = findByClient(tenantId, clientId);
    if (client.id.value != 0)
      remove(client);
  }
}
