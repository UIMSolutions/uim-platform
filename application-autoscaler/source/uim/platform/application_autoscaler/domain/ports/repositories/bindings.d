/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_autoscaler.domain.ports.repositories.bindings;

import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

interface AppBindingRepository {
  bool             existsById(AppBindingId id);
  AppBindingEntity findById(AppBindingId id);
  AppBindingEntity findByAppGuid(string appGuid);
  AppBindingEntity[] findAll();
  AppBindingEntity[] findByTenantId(TenantId tenantId);
  void save(AppBindingEntity binding);
  void update(AppBindingEntity binding);
  void remove(AppBindingId id);
  size_t count();
}
