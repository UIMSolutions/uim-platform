/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.infrastructure.persistence.repositories.applications;
// import uim.platform.identity_authentication.domain.entities.application;
// import uim.platform.identity_authentication.domain.types;
// import uim.platform.identity_authentication.domain.ports.repositories.application;

import uim.platform.identity_authentication;

mixin(ShowModule!());
@safe:
/// In-memory adapter for application/service provider persistence.
class MemoryApplicationRepository : TenantRepository!(Application, ApplicationId), ApplicationRepository {
  
  bool existsByClient(TenantId tenantId, string clientId) {
    return findByTenant(tenantId).any!(item => item.clientId == clientId);
  }

  Application findByClient(TenantId tenantId, string clientId) {
    foreach (a; findByTenant(tenantId)) {
      if (a.clientId == clientId)
        return a;
    }
    return Application.init;
  }

  void removeByClient(TenantId tenantId, string clientId) {
    remove(findByClient(tenantId, clientId));
  }
}
