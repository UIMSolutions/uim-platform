/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.domain.ports.repositories.application_jobs;
// import uim.platform.abap_environment.domain.entities.application_job;

import uim.platform.abap_environment;

// // mixin(ShowModule!());

@safe:
/// Port: outgoing - application job persistence.
interface ApplicationJobRepository : ITenantRepository!(ApplicationJob, ApplicationJobId) {

  size_t countBySystem(TenantId tenantId, SystemInstanceId systemId);
  ApplicationJob[] findBySystem(TenantId tenantId, SystemInstanceId systemId);
  void removeBySystem(TenantId tenantId, SystemInstanceId systemId);

  size_t countByStatus(TenantId tenantId, SystemInstanceId systemId, JobStatus status);
  ApplicationJob[] findByStatus(TenantId tenantId, SystemInstanceId systemId, JobStatus status);
  void removeByStatus(TenantId tenantId, SystemInstanceId systemId, JobStatus status);

}
