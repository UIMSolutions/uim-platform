/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_autoscaler.infrastructure.persistence.memory.policies;

import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

class MemoryScalingPolicyRepository : ScalingPolicyRepository {
  private ScalingPolicyEntity[string] store;

  override bool existsById(PolicyId id) {
    return (id in store) !is null;
  }

  override ScalingPolicyEntity findById(PolicyId id) {
    auto p = id in store;
    return p ? *p : ScalingPolicyEntity.init;
  }

  override ScalingPolicyEntity findByAppId(AppBindingId appId) {
    foreach (p; store.byValue)
      if (p.appId == appId && p.status == PolicyStatus.active) return p;
    return ScalingPolicyEntity.init;
  }

  override ScalingPolicyEntity[] findAll() {
    ScalingPolicyEntity[] result;
    foreach (p; store.byValue) result ~= p;
    return result;
  }

  override ScalingPolicyEntity[] findByTenantId(TenantId tenantId) {
    ScalingPolicyEntity[] result;
    foreach (p; store.byValue)
      if (p.tenantId == tenantId) result ~= p;
    return result;
  }

  override void save(ScalingPolicyEntity policy) {
    store[policy.id] = policy;
  }

  override void update(ScalingPolicyEntity policy) {
    store[policy.id] = policy;
  }

  override void remove(PolicyId id) {
    store.remove(id);
  }

  override size_t count() {
    return store.length;
  }
}
