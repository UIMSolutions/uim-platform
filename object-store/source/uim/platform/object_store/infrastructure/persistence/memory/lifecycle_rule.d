/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.infrastructure.persistence.memory.lifecycle_rule;

// import uim.platform.object_store.domain.types;
// import uim.platform.object_store.domain.entities.lifecycle_rule;
// import uim.platform.object_store.domain.ports.repositories.lifecycle_rule;


 
import uim.platform.object_store;

mixin(ShowModule!());

@safe:
class MemoryLifecycleRuleRepository : TenantRepository!(LifecycleRule, LifecycleRuleId),  LifecycleRuleRepository {

  size_t countByBucket(TenantId tenantId, BucketId bucketId) {
    return findByBucket(tenantId, bucketId).length;
  }
  
  LifecycleRule[] filterByBucket(LifecycleRule[] rules, BucketId bucketId) {
    return rules.filter!(e => e.bucketId == bucketId).array;
  }

  LifecycleRule[] findByBucket(TenantId tenantId, BucketId bucketId) {
    return findByTenant(tenantId).filter!(e => e.bucketId == bucketId).array;
  }
  
  void removeByBucket(TenantId tenantId, BucketId bucketId) {
    findByBucket(tenantId, bucketId).each!(rule => remove(rule));
  }

}
