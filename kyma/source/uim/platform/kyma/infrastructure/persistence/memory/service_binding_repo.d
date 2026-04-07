/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.infrastructure.persistence.memory.service_binding_repo;

import uim.platform.kyma.domain.types;
import uim.platform.kyma.domain.entities.service_binding;
import uim.platform.kyma.domain.ports.repositories.service_bindings;

// import std.algorithm : filter;
// import std.array : array;

class MemoryServiceBindingRepository : ServiceBindingRepository {
  private ServiceBinding[ServiceBindingId] store;

  ServiceBinding findById(ServiceBindingId id) {
    if (auto p = id in store)
      return *p;
    return ServiceBinding.init;
  }

  ServiceBinding findByName(NamespaceId nsId, string name) {
    foreach (ref e; store.byValue())
      if (e.namespaceId == nsId && e.name == name)
        return e;
    return ServiceBinding.init;
  }

  ServiceBinding[] findByNamespace(NamespaceId nsId) {
    return store.byValue().filter!(e => e.namespaceId == nsId).array;
  }

  ServiceBinding[] findByServiceInstance(ServiceInstanceId instanceId) {
    return store.byValue().filter!(e => e.serviceInstanceId == instanceId).array;
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
}
