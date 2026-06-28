/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.infrastructure.persistence.memory.cors_rule;

// import uim.platform.object_store.domain.types;
// import uim.platform.object_store.domain.entities.cors_rule;
// import uim.platform.object_store.domain.ports.repositories.cors_rule;
// 

 
import uim.platform.object_store;

mixin(ShowModule!());

@safe:
class MemoryCorsRuleRepository : TenantRepository!(CorsRule, CorsRuleId), CorsRuleRepository {

  size_t countByBucket(TenantId tenantId, BucketId bucketId) {
    return findByBucket(tenantId, bucketId).length;
  }

  CorsRule[] filterByBucket(CorsRule[] rules, BucketId bucketId) {
    return rules.filter!(e => e.bucketId == bucketId).array;
  }

  CorsRule[] findByBucket(TenantId tenantId, BucketId bucketId) {
    return filterByBucket(find(tenantId), bucketId);
  }

  void removeByBucket(TenantId tenantId, BucketId bucketId) {
    findByBucket(tenantId, bucketId).each!(rule => remove(rule));
  }

}
