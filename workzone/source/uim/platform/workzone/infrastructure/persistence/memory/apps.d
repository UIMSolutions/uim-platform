/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.infrastructure.persistence.memory.app;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.app_registration;
import uim.platform.workzone.domain.ports.repositories.apps;

// import std.algorithm : filter;
// import std.array : array;

class MemoryAppRepository : TenantRepository!(AppRegistration, AppId), AppRepository {

  size_t countByStatus(TenantId tenantId, AppStatus status) {
    return findByStatus(tenantId, status).length;
  }

  AppRegistration[] findByStatus(TenantId tenantId, AppStatus status) {
    return findByTenant(tenantId).filter!(a => a.status == status).array;
  }

  void removeByStatus(TenantId tenantId, AppStatus status) {
    return findByStatus(tenantId, status).each!(a => remove(a));
  }
}
