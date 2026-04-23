/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.domain.ports.repositories.application_jobs;

// import uim.platform.abap_environment.domain.entities.application_job;
// import uim.platform.abap_environment.domain.types;
import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:
/// Port: outgoing - application job persistence.
interface ApplicationJobRepository : ITenantRepository!(ApplicationJob, ApplicationJobId) {

  size_t countBySystem(SystemInstanceId systemId);
  ApplicationJob[] findBySystem(SystemInstanceId systemId);
  void removeBySystem(SystemInstanceId systemId);

  size_t countByStatus(SystemInstanceId systemId, JobStatus status);
  ApplicationJob[] findByStatus(SystemInstanceId systemId, JobStatus status);
  void removeByStatus(SystemInstanceId systemId, JobStatus status);

}
