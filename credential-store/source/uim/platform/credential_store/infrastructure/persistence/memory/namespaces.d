/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.credential_store.infrastructure.persistence.memory.namespaces;

import uim.platform.credential_store.domain.entities.namespace;
import uim.platform.credential_store.domain.ports.repositories.namespaces;
import uim.platform.credential_store.domain.types;

import std.algorithm : filter;
import std.array : array;

class MemoryNamespaceRepository : NamespaceRepository {
  private Namespace[NamespaceId] store;

  Namespace findById(NamespaceId id) {
    if (auto p = id in store)
      return *p;
    return Namespace.init;
  }

  Namespace findByName(TenantId tenantId, string name) {
    foreach (ns; store) {
      if (ns.tenantId == tenantId && ns.name == name)
        return ns;
    }
    return Namespace.init;
  }

  Namespace[] findByTenant(TenantId tenantId) {
    return store.values.filter!(ns => ns.tenantId == tenantId).array;
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

  size_t countByTenant(TenantId tenantId) {
    return store.values.filter!(ns => ns.tenantId == tenantId).array.length;
  }
}
