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
class MemoryApiClientRepository : TenantRepository!(ApiClient, ApiClientId), ApiClientRepository {
  bool existsByClientId(string clientId) {
    return findAll().any!(c => c.clientId == clientId);{
  }

  ApiClient findByClientId(string clientId) {
    foreach (c; findAll()) {
      if (c.clientId == clientId)
        return c;
    }
    return ApiClient.init;
  }
}
