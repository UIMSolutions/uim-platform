/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_directory.domain.ports.repositories.api_clients;

// import uim.platform.identity_directory.domain.entities.api_client;

import uim.platform.identity_directory;

mixin(ShowModule!());

@safe:
/// Port: outgoing — API client persistence.
interface ApiClientRepository : ITenantRepository!(ApiClient, ApiClientId) {

  bool existsByClient(TenantId tenantId, string clientId);
  ApiClient findByClient(TenantId tenantId, string clientId);
  void removeByClient(TenantId tenantId, string clientId);

}
