/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_autoscaler.infrastructure.persistence.memory.bindings;

import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

class MemoryAppBindingRepository : AppBindingRepository {
  private AppBindingEntity[string] store;

  override bool existsById(AppBindingId id) {
    return (id in store) !is null;
  }

  override AppBindingEntity findById(AppBindingId id) {
    auto p = id in store;
    return p ? *p : AppBindingEntity.init;
  }

  override AppBindingEntity findByAppGuid(string appGuid) {
    foreach (b; store.byValue)
      if (b.appGuid == appGuid) return b;
    return AppBindingEntity.init;
  }

  override AppBindingEntity[] findAll() {
    AppBindingEntity[] result;
    foreach (b; store.byValue) result ~= b;
    return result;
  }

  override AppBindingEntity[] findByTenantId(TenantId tenantId) {
    AppBindingEntity[] result;
    foreach (b; store.byValue)
      if (b.tenantId == tenantId) result ~= b;
    return result;
  }

  override void save(AppBindingEntity binding) {
    store[binding.id] = binding;
  }

  override void update(AppBindingEntity binding) {
    store[binding.id] = binding;
  }

  override void remove(AppBindingId id) {
    store.remove(id);
  }

  override size_t count() {
    return store.length;
  }
}
