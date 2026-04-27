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
class MemoryNamespaceRepository : TenantRepository!(Namespace, NamespaceId), NamespaceRepository {

  bool existsByName(KymaEnvironmentId envId, string name) {
    return findByEnvironment(envId).any!(e => e.name == name);
  }

  Namespace findByName(KymaEnvironmentId envId, string name) {
    foreach (e; findByEnvironment(envId))
      if (e.name == name)
        return e;
    return Namespace.init;
  }

  size_t countByEnvironment(KymaEnvironmentId envId) {
    return findByEnvironment(envId).length;
  }
  Namespace[] filterByEnvironment(Namespace[] namespaces, KymaEnvironmentId envId) {
    return namespaces.filter!(e => e.environmentId == envId).array;
  }
  Namespace[] findByEnvironment(KymaEnvironmentId envId) {
    return findAll().filter!(e => e.environmentId == envId).array;
  }
  void removeByEnvironment(KymaEnvironmentId envId) {
    findByEnvironment(envId).each!(e => remove(e));
  }

}
