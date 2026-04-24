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

class MemoryNamespaceRepository : TenantRepository!(Namespace, NamespaceId), NamespaceRepository {

  bool existsByName(TenantId tenantId, string name) {
    return findByName(tenantId, name).id.value != "";
  }

  Namespace findByName(TenantId tenantId, string name) {
    foreach (ns; findByTenant(tenantId)) {
      if (ns.name == name)
        return ns;
    }
    return Namespace.init;
  }

}
