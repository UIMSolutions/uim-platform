/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.domain.ports.repositories.clients;

import uim.platform.master_data_integration.domain.entities.client;
import uim.platform.master_data_integration.domain.types;

/// Port: outgoing — connected client system persistence.
interface ClientRepository : ITenantRepository!(Client, ClientId) {

  size_t countByStatus(TenantId tenantId, ClientStatus status);
  Client[] findByStatus(TenantId tenantId, ClientStatus status);
  void removeByStatus(TenantId tenantId, ClientStatus status);

  size_t countByType(TenantId tenantId, ClientType clientType);
  Client[] findByType(TenantId tenantId, ClientType clientType);
  void removeByType(TenantId tenantId, ClientType clientType);

}
