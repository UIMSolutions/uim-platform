/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.directory.domain.ports.repositories.api_clients;

import uim.platform.identity.directory.domain.entities.api_client;
import uim.platform.identity.directory.domain.types;

/// Port: outgoing — API client persistence.
interface ApiClientRepository
{
  ApiClient findById(ApiClientId id);
  ApiClient findByClientId(string clientId);
  ApiClient[] findByTenant(TenantId tenantId, uint offset = 0, uint limit = 100);
  void save(ApiClient client);
  void update(ApiClient client);
  void remove(ApiClientId id);
}
