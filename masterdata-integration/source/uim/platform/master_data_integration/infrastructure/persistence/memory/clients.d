/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.infrastructure.persistence.memory.client;

import uim.platform.master_data_integration.domain.types;
import uim.platform.master_data_integration.domain.entities.client;
import uim.platform.master_data_integration.domain.ports.repositories.clients;

// import std.algorithm : filter;
// import std.array : array;

class MemoryClientRepository : TenantRepository!(Client, ClientId), ClientRepository {

  size_t countByStatus(TenantId tenantId, ClientStatus status) {
    return findByStatus(tenantId, status).length;
  }
  Client[] filterByStatus(Client[] clients, ClientStatus status, size_t offset = 0, size_t limit = 0) {
    return (limit == 0)
        ? clients.filter!(e => e.status == status).skip(offset).array
        : clients.filter!(e => e.status == status).skip(offset).take(limit).array;
  }

  Client[] findByStatus(TenantId tenantId, ClientStatus status) {
    return filterByStatus(findByTenant(tenantId), status, 0, 0);
  }
  void removeByStatus(TenantId tenantId, ClientStatus status) {
    filterByStatus(findByTenant(tenantId), status, 0, 0).each!(e => remove(e));
  }

   size_t countByType(TenantId tenantId, ClientType clientType) {
    return findByType(tenantId, clientType).length;
  }
  Client[] filterByType(Client[] clients, ClientType clientType, size_t offset = 0, size_t limit = 0) {
    return (limit == 0)
        ? clients.filter!(e => e.clientType == clientType).skip(offset).array
        : clients.filter!(e => e.clientType == clientType).skip(offset).take(limit).array;
  }

  Client[] findByType(TenantId tenantId, ClientType clientType) {
    return filterByType(findByTenant(tenantId), clientType, 0, 0);
  }

  void removeByType(TenantId tenantId, ClientType clientType) {
    filterByType(findByTenant(tenantId), clientType, 0, 0).each!(e => remove(e));
  }

}
