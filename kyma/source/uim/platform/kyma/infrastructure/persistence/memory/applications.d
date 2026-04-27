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

  bool existsByName(KymaEnvironmentId envId, string name) {
    return findByEnvironment(envId).any!(e => e.name == name);
  }

  Application findByName(KymaEnvironmentId envId, string name) {
    foreach (e; findByEnvironment(envId))
      if (e.name == name)
        return e;
    return Application.init;
  }

size_t countByEnvironment(KymaEnvironmentId envId) {
    return findByEnvironment(envId).length;
  }
  Application[] filterByEnvironment(Application[] apps, KymaEnvironmentId envId) {
    return apps.filter!(e => e.environmentId == envId).array;
  }
  Application[] findByEnvironment(KymaEnvironmentId envId) {
    return filterByEnvironment(findAll().array, envId);
  }
  void removeByEnvironment(KymaEnvironmentId envId) {
    findByEnvironment(envId).each!(e => remove(e.id));
  }

  size_t countByStatus(AppConnectivityStatus status) {
    return findByStatus(status).length;
  }
  Application[] filterByStatus(Application[] apps, AppConnectivityStatus status) {
    return apps.filter!(e => e.status == status).array;
  }
  Application[] findByStatus(AppConnectivityStatus status) {
    return filterByStatus(findAll().array, status);
  }
  void removeByStatus(AppConnectivityStatus status) {
    findByStatus(status).each!(e => remove(e.id));
  }

}
