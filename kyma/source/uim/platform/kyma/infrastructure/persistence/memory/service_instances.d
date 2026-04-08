/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.infrastructure.persistence.memory.in_memory_service_instance;

import uim.platform.kyma.domain.types;
import uim.platform.kyma.domain.entities.service_instance;
import uim.platform.kyma.domain.ports.repositories.service_instances;

// import std.algorithm : filter;
// import std.array : array;

class MemoryServiceInstanceRepository : ServiceInstanceRepository {
  private ServiceInstance[ServiceInstanceId] store;

  ServiceInstance findById(ServiceInstanceId id) {
    if (auto p = id in store)
      return *p;
    return ServiceInstance.init;
  }

  ServiceInstance findByName(NamespaceId nsId, string name) {
    foreach (ref e; store.byValue())
      if (e.namespaceId == nsId && e.name == name)
        return e;
    return ServiceInstance.init;
  }

  ServiceInstance[] findByNamespace(NamespaceId nsId) {
    return store.byValue().filter!(e => e.namespaceId == nsId).array;
  }

  ServiceInstance[] findByEnvironment(KymaEnvironmentId envId) {
    return store.byValue().filter!(e => e.environmentId == envId).array;
  }

  ServiceInstance[] findByOffering(string offeringName) {
    return store.byValue().filter!(e => e.serviceOfferingName == offeringName).array;
  }

  void save(ServiceInstance inst) {
    store[inst.id] = inst;
  }

  void update(ServiceInstance inst) {
    store[inst.id] = inst;
  }

  void remove(ServiceInstanceId id) {
    store.remove(id);
  }
}
