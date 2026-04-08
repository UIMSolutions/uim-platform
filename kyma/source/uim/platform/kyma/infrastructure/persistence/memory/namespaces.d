/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.infrastructure.persistence.memory.namespaces;

// import uim.platform.kyma.domain.types;
// import uim.platform.kyma.domain.entities.namespace;
// import uim.platform.kyma.domain.ports.repositories.namespaces;

// import std.algorithm : filter;
// import std.array : array;
import uim.platform.kyma;

mixin(ShowModule!());

@safe:
class MemoryNamespaceRepository : NamespaceRepository {
  private Namespace[NamespaceId] store;

  Namespace findById(NamespaceId id) {
    if (auto p = id in store)
      return *p;
    return Namespace.init;
  }

  Namespace findByName(KymaEnvironmentId envId, string name) {
    foreach (ref e; store.byValue())
      if (e.environmentId == envId && e.name == name)
        return e;
    return Namespace.init;
  }

  Namespace[] findByEnvironment(KymaEnvironmentId envId) {
    return store.byValue().filter!(e => e.environmentId == envId).array;
  }

  Namespace[] findByTenant(TenantId tenantId) {
    return store.byValue().filter!(e => e.tenantId == tenantId).array;
  }

  void save(Namespace ns) {
    store[ns.id] = ns;
  }

  void update(Namespace ns) {
    store[ns.id] = ns;
  }

  void remove(NamespaceId id) {
    store.remove(id);
  }
}
