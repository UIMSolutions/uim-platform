/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.infrastructure.persistence.memory.service_binding;

import uim.platform.object_store.domain.types;
import uim.platform.object_store.domain.entities.service_binding;
import uim.platform.object_store.domain.ports.repositories.service_binding;

// import std.algorithm : filter;
// import std.array : array;

class MemoryServiceBindingRepository : ServiceBindingRepository {
  private ServiceBinding[ServiceBindingId] store;

  ServiceBinding findById(ServiceBindingId id) {
    if (auto p = id in store)
      return *p;
    return null;
  }

  ServiceBinding[] findByBucket(BucketId bucketId) {
    return store.byValue().filter!(e => e.bucketId == bucketId).array;
  }

  ServiceBinding[] findByTenant(TenantId tenantId) {
    return store.byValue().filter!(e => e.tenantId == tenantId).array;
  }

  void save(ServiceBinding entity) {
    store[entity.id] = entity;
  }

  void update(ServiceBinding entity) {
    store[entity.id] = entity;
  }

  void remove(ServiceBindingId id) {
    store.remove(id);
  }
}
