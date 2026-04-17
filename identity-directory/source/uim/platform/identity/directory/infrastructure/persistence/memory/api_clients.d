/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.directory.infrastructure.persistence.memory.api_clients;

// import uim.platform.identity.directory.domain.entities.api_client;
// import uim.platform.identity.directory.domain.types;
// import uim.platform.identity.directory.domain.ports.repositories.api_clients;
import uim.platform.identity.directory;

mixin(ShowModule!());

@safe:
/// In-memory adapter for API client persistence.
class MemoryApiClientRepository : ApiClientRepository {
  private ApiClient[ApiClientId] store;

  ApiClient findById(ApiClientId id) {
    if (auto p = id in store)
      return *p;
    return ApiClient.init;
  }

  ApiClient findByClientId(string clientId) {
    foreach (c; store.byValue()) {
      if (c.clientId == clientId)
        return c;
    }
    return ApiClient.init;
  }

  ApiClient[] findByTenant(TenantId tenantId, uint offset = 0, uint limit = 100) {
    ApiClient[] result;
    uint idx;
    foreach (c; store.byValue()) {
      if (c.tenantId == tenantId) {
        if (idx >= offset && result.length < limit)
          result ~= c;
        idx++;
      }
    }
    return result;
  }

  void save(ApiClient client) {
    store[client.id] = client;
  }

  void update(ApiClient client) {
    store[client.id] = client;
  }

  void remove(ApiClientId id) {
    store.remove(id);
  }
}
