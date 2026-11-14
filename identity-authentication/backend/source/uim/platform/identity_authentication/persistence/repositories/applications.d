/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.persistence.repositories.applications;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

class ApplicationRepository : TenantRepository!(Application, ApplicationId), IApplicationRepository {
  mixin TenantRepositoryTemplate!(ApplicationRepository, Application, ApplicationId);

  bool existsByClient(TenantId tenantId, string clientId) {
    return !findByClient(tenantId, clientId).isNull;
  }

  Application findByClient(TenantId tenantId, string clientId) {
    if (clientId.length == 0)
      return Application.init;
    foreach (a; findByTenant(tenantId))
      if (a.clientId == clientId)
        return a;
    return Application.init;
  }

  void removeByClient(TenantId tenantId, string clientId) {
    remove(findByClient(tenantId, clientId));
  }
}
///
unittest {
  assert(tenantRepositoryTest(new ApplicationRepository()));
}
