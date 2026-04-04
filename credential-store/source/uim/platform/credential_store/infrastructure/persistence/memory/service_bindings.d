/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.credential_store.infrastructure.persistence.memory.service_binding_repo;

import uim.platform.credential_store.domain.entities.service_binding;
import uim.platform.credential_store.domain.ports.repositories.service_bindings;
import uim.platform.credential_store.domain.types;

import std.algorithm : filter;
import std.array : array;

class MemoryServiceBindingRepository : ServiceBindingRepository {
  private ServiceBinding[ServiceBindingId] store;

  ServiceBinding findById(ServiceBindingId id) {
    if (auto p = id in store)
      return *p;
    return ServiceBinding.init;
  }

  ServiceBinding findByClientId(string clientId) {
    foreach (ref b; store) {
      if (b.clientId == clientId)
        return b;
    }
    return ServiceBinding.init;
  }

  ServiceBinding[] findByTenant(TenantId tenantId) {
    return store.values.filter!(b => b.tenantId == tenantId).array;
  }

  void save(ServiceBinding binding) {
    store[binding.id] = binding;
  }

  void update(ServiceBinding binding) {
    store[binding.id] = binding;
  }

  void remove(ServiceBindingId id) {
    store.remove(id);
  }

  long countByTenant(TenantId tenantId) {
    return cast(long) store.values.filter!(b => b.tenantId == tenantId).array.length;
  }
}
