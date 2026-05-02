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

class MemoryApplicationJobRepository : TenantRepository!(ApplicationJob, ApplicationJobId), ApplicationJobRepository {

  // #region BySystem
  size_t countBySystem(SystemInstanceId systemId) {
    return findBySystem(systemId).length;
  }
  ApplicationJob[] findBySystem(SystemInstanceId systemId) {
    return findAll().filter!(e => e.systemInstanceId == systemId).array;
  }
  void removeBySystem(SystemInstanceId systemId) {
    findBySystem(systemId).each!(e => remove(e));
  }
  // #endregion BySystem

  // #region ByStatus
  size_t countByStatus(SystemInstanceId systemId, JobStatus status) {
    return findByStatus(systemId, status).length;
  }
  ApplicationJob[] findByStatus(SystemInstanceId systemId, JobStatus status) {
    return findAll().filter!(e => e.systemInstanceId == systemId && e.status == status).array;
  }
  void removeByStatus(SystemInstanceId systemId, JobStatus status) {
    findByStatus(systemId, status).each!(e => remove(e));
  }
  // #endregion ByStatus

}
