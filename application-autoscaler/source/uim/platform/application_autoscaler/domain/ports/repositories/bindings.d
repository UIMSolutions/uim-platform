/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_autoscaler.domain.ports.repositories.bindings;

import uim.platform.application_autoscaler;

// mixin(ShowModule!());

@safe:

interface AppBindingRepository : ITenantRepository!(AppBindingEntity, AppBindingId) {

  bool existsByAppGuid(string appGuid);
  AppBindingEntity findByAppGuid(string appGuid);
  void removeByAppGuid(string appGuid);
  
}
