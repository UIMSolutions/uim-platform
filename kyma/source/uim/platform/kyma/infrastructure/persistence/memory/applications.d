/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.infrastructure.persistence.memory.applications;

// import uim.platform.kyma.domain.types;
// import uim.platform.kyma.domain.entities.application;
// import uim.platform.kyma.domain.ports.repositories.applications;

// import std.algorithm : filter;
// import std.array : array;
import uim.platform.kyma;

mixin(ShowModule!());

@safe:
class MemoryApplicationRepository : TenantRepository!(Application, ApplicationId), ApplicationRepository {
  private Application[ApplicationId] store;

  bool existsById(ApplicationId id) {
    return (id in store) ? true : false;
  }

  Application findById(ApplicationId id) {
    if (existsById(id))
      return store[id];
    return Application.init;
  }

  bool existsByName(KymaEnvironmentId envId, string name) {
    return findByEnvironment(envId).any!(e => e.name == name);
  }

  Application findByName(KymaEnvironmentId envId, string name) {
    foreach (e; findByEnvironment(envId))
      if (e.name == name)
        return e;
    return Application.init;
  }

  Application[] findByEnvironment(KymaEnvironmentId envId) {
    return findAll()r!(e => e.environmentId == envId).array;
  }

  Application[] findByStatus(AppConnectivityStatus status) {
    return findAll()r!(e => e.status == status).array;
  }

  Application[] findByTenant(TenantId tenantId) {
    return findAll()r!(e => e.tenantId == tenantId).array;
  }

  void save(Application app) {
    store[app.id] = app;
  }

  void update(Application app) {
    if (existsById(app.id))
      store[app.id] = app;
  }

  void remove(ApplicationId id) {
    if (existsById(id))
      store.remove(id);
  }
}
