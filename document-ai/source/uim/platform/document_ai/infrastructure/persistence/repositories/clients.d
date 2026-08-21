/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.infrastructure.persistence.repositories.clients;

// import uim.platform.document_ai.domain.entities.client;
// import uim.platform.document_ai.domain.ports.repositories.clients;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:
class ClientRepository : TenantRepository!(Client, ClientId), IClientRepository {

  size_t countByName(TenantId tenantId, string name) {
    return findByName(tenantId, name).length;
  }

  Client[] filterByName(Client[] clients, string name) {
    return clients.filter!(c => c.name == name).array;
  }

  Client[] findByName(TenantId tenantId, string name) {
    return filterByName(findByTenant(tenantId), name);
  }

  void removeByName(TenantId tenantId, string name) {
    findByName(tenantId, name).each!(e => remove(e));
  }
  
  size_t countByQuota(TenantId tenantId, int quota) {
    return findByQuota(tenantId, quota).length;
  }

  Client[] filterByQuota(Client[] clients, int quota) {
    return clients.filter!(c => c.quota == quota).array;
  }

  Client[] findByQuota(TenantId tenantId, int quota) {
    return filterByQuota(findByTenant(tenantId), quota);
  }

  void removeByQuota(TenantId tenantId, int quota) {
    findByQuota(tenantId, quota).each!(e => remove(e));
  }

}
