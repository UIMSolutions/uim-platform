/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.persistence.repositories.applications;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

class ApplicationRepository : KymaRepository!(KymaApplication, ApplicationId), IApplicationRepository {
  this() {
    super();
  }

  this(ITenantStore!(KymaApplication, ApplicationId) store) {
    super(store);
  }

  KymaApplication findByName(TenantId tenantId, KymaEnvironmentId environmentId, string name) {
    return first(tenantId, (e) => e.environmentId == environmentId && e.name == name);
  }

  KymaApplication[] findByEnvironment(TenantId tenantId, KymaEnvironmentId environmentId) {
    return where(tenantId, (e) => e.environmentId == environmentId);
  }
}

///
unittest {
  assert(tenantRepositoryTest(new ApplicationRepository()));
}
