/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.infrastructure.persistence.memory.application_jobs;

// import uim.platform.abap_environment.domain.entities.application_job;
// import uim.platform.abap_environment.domain.ports.repositories.application_jobs;

import uim.platform.abap_environment;

// mixin(ShowModule!());

@safe:

class MemoryApplicationJobRepository : TenantRepository!(ApplicationJob, ApplicationJobId), ApplicationJobRepository {

  // #region BySystem
  size_t countBySystem(TenantId tenantId, SystemInstanceId systemId) {
    return findBySystem(tenantId, systemId).length;
  }
  ApplicationJob[] filterBySystem(ApplicationJob[] jobs, SystemInstanceId systemId) {
    return jobs.filter!(e => e.systemInstanceId == systemId).array;
  }
  ApplicationJob[] findBySystem(TenantId tenantId, SystemInstanceId systemId) {
    return filterBySystem(findByTenant(tenantId), systemId);
  }
  void removeBySystem(TenantId tenantId, SystemInstanceId systemId) {
    findBySystem(tenantId, systemId).each!(e => remove(e));
  }
  // #endregion BySystem

  // #region ByStatus
  size_t countByStatus(TenantId tenantId, SystemInstanceId systemId, JobStatus status) {
    return findByStatus(tenantId, systemId, status).length;
  }
  ApplicationJob[] filterByStatus(ApplicationJob[] jobs, JobStatus status) {
    return jobs.filter!(e => e.status == status).array;
  }
  ApplicationJob[] findByStatus(TenantId tenantId, SystemInstanceId systemId, JobStatus status) {
    return filterByStatus(findBySystem(tenantId, systemId), status);
  }
  void removeByStatus(TenantId tenantId, SystemInstanceId systemId, JobStatus status) {
    findByStatus(tenantId, systemId, status).each!(e => remove(e));
  }
  // #endregion ByStatus

}
