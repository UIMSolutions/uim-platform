/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.infrastructure.persistence.repositories.service_binding;

// import uim.platform.object_store.domain.types;
// import uim.platform.object_store.domain.entities.service_binding;
// import uim.platform.object_store.domain.ports.repositories.service_binding;

import uim.platform.object_store;

mixin(ShowModule!());

@safe:
class MemoryServiceBindingRepository : TenantRepository!(ServiceBinding, ServiceBindingId), ServiceBindingRepository {

  size_t countByBucket(TenantId tenantId, BucketId bucketId) {
    return findByBucket(tenantId, bucketId).length;
  }

  ServiceBinding[] filterByBucket(ServiceBinding[] bindings, BucketId bucketId) {
    return bindings.filter!(e => e.bucketId == bucketId).array;
  }

  ServiceBinding[] findByBucket(TenantId tenantId, BucketId bucketId) {
    return filterByBucket(findByTenant(tenantId), bucketId);
  }
  void removeByBucket(TenantId tenantId, BucketId bucketId) {
    findByBucket(tenantId, bucketId).each!(e => remove(e));
  }

}
