/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.persistence.repositories.environments;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

class EnvironmentRepository : KymaRepository!(KymaEnvironment, KymaEnvironmentId), IEnvironmentRepository {
  this() {
    super();
  }

  this(ITenantStore!(KymaEnvironment, KymaEnvironmentId) store) {
    super(store);
  }

  KymaEnvironment findByName(TenantId tenantId, string name) {
    return first(tenantId, (e) => e.name == name);
  }

  KymaEnvironment[] findBySubaccount(TenantId tenantId, SubaccountId subaccountId) {
    return where(tenantId, (e) => e.subaccountId == subaccountId);
  }

  KymaEnvironment[] findByStatus(TenantId tenantId, EnvironmentStatus status) {
    return where(tenantId, (e) => e.status == status);
  }
}

///
unittest {
  assert(tenantRepositoryTest(new EnvironmentRepository()));
}
