/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.domain.ports.clients;

import uim.platform.master_data_integration.domain.entities.client;
import uim.platform.master_data_integration.domain.types;

/// Port: outgoing — connected client system persistence.
interface ClientRepository {
  Client findById(ClientId id);
  Client[] findByTenant(TenantId tenantId);
  Client[] findByStatus(TenantId tenantId, ClientStatus status);
  Client[] findByType(TenantId tenantId, ClientType clientType);
  void save(Client client);
  void update(Client client);
  void remove(ClientId id);
}
