/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_autoscaler.infrastructure.persistence.memory.bindings;

import uim.platform.application_autoscaler;

// mixin(ShowModule!());

@safe:

class MemoryAppBindingRepository : TentRepository!(AppBinding, AppBindingId), AppBindingRepository {
  bool existsByAppGuid(TenantId tenantId, string appGuid) {
    return findByAppGuid(tenantId, appGuid).isNull ? false : true;
  }

  AppBinding findByAppGuid(TenantId tenantId, string appGuid) {
    foreach (b; findByTenant(tenantId))
      if (b.appGuid == appGuid) return b;
    return AppBinding.init;
  }

  void removeByAppGuid(TenantId tenantId, string appGuid) {
    remove(findByAppGuid(tenantId, appGuid));
  }

}
