/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration.automation.infrastructure.persistence.memory.systems;

import uim.platform.integration.automation.domain.types;
import uim.platform.integration.automation.domain.entities.system_connection;

// import uim.platform.integration.automation.domain.ports.repositories.systems;
import uim.platform.integration.automation.domain.ports;

// import std.algorithm : filter;
// import std.array : array;

class MemorySystemRepository : TenantRepository!(SystemConnection, SystemConnectionId), SystemRepository {

  size_t countByType(TenantId tenantId, SystemType systemType) {
    return findByType(tenantId, systemType).length;
  }

  SystemConnection[] filterByType(SystemConnection[] systems, SystemType systemType) {
    return systems.filter!(e => e.systemType == systemType).array;
  }

  SystemConnection[] findByType(TenantId tenantId, SystemType systemType) {
    return filterByType(findByTenant(tenantId), systemType);
  }

  void removeByType(TenantId tenantId, SystemType systemType) {
    findByType(tenantId, systemType).each!(e => remove(e));
  }

  size_t countByStatus(TenantId tenantId, ConnectionStatus status) {
    return findByStatus(tenantId, status).length;
  }

  SystemConnection[] filterByStatus(SystemConnection[] systems, ConnectionStatus status) {
    return systems.filter!(e => e.status == status).array;
  }

  SystemConnection[] findByStatus(TenantId tenantId, ConnectionStatus status) {
    return filterByStatus(findByTenant(tenantId), status);
  }

  void removeByStatus(TenantId tenantId, ConnectionStatus status) {
    findByStatus(tenantId, status).each!(e => remove(e));
  }

}
