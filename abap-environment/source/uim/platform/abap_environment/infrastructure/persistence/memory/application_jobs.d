/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.infrastructure.persistence.memory.application_jobs;

// import uim.platform.abap_environment.domain.types;
// import uim.platform.abap_environment.domain.entities.application_job;
// import uim.platform.abap_environment.domain.ports.repositories.application_jobs;
// 
// // import std.algorithm : filter;
// // import std.array : array;

import uim.platform.abap_environment;

mixin(ShowModule!());
@safe:

class MemoryApplicationJobRepository : MemoryTenantRepository!(ApplicationJob, ApplicationJobId), ApplicationJobRepository {
  // private ApplicationJob[ApplicationJobId] store;
// 
  // ApplicationJob findById(ApplicationJobId id) {
    // if (id in store)
      // return store[id];
    // return ApplicationJob.init;
  // }

  ApplicationJob[] findBySystem(SystemInstanceId systemId) {
    return findAll().filter!(e => e.systemInstanceId == systemId).array;
  }

// /  ApplicationJob[] findByTenant(TenantId tenantId) {
// /    return findAll().filter!(e => e.tenantId == tenantId).array;
// /  }

  ApplicationJob[] findByStatus(SystemInstanceId systemId, JobStatus status) {
    return findAll().filter!(e => e.systemInstanceId == systemId && e.status == status).array;
  }

  // void save(ApplicationJob job) {
  //   store[job.id] = job;
  // }

  // void update(ApplicationJob job) {
  //   store[job.id] = job;
  // }

  // void remove(ApplicationJobId id) {
  //   store.remove(id);
  // }
}
