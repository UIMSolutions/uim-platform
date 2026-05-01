/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.infrastructure.persistence.memory.service_bindings;

// import uim.platform.kyma.domain.types;
// import uim.platform.kyma.domain.entities.service_binding;
// import uim.platform.kyma.domain.ports.repositories.service_bindings;

// import std.algorithm : filter;
// import std.array : array;
import uim.platform.kyma;

mixin(ShowModule!());

@safe:
class MemoryServiceBindingRepository : ServiceBindingRepository {
  private ServiceBinding[ServiceBindingId] store;

  bool existsById(ServiceBindingId id) {
    return (id in store) ? true : false;
  }

  ServiceBinding findById(ServiceBindingId id) {
    if (existsById(id))
      return store[id];
    return ServiceBinding.init;
  }

  bool existsByName(NamespaceId nsId, string name) {
    return findByNamespace(nsId).any!(e => e.name == name);
  }

  ServiceBinding findByName(NamespaceId nsId, string name) {
    foreach (e; findByNamespace(nsId))
      if (e.name == name)
        return e;
    return ServiceBinding.init;
  }

  ServiceBinding[] findByNamespace(NamespaceId nsId) {
    return findAll().filter!(e => e.namespaceId == nsId).array;
  }

  ServiceBinding[] findByServiceInstance(ServiceInstanceId instanceId) {
    return findAll().filter!(e => e.serviceInstanceId == instanceId).array;
  }

  void save(ServiceBinding binding) {
    store[binding.id] = binding;
  }

  void update(ServiceBinding binding) {
    store[binding.id] = binding;
  }

  void remove(ServiceBindingId id) {
    store.removeById(id);
  }
}
