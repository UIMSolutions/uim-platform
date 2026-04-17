/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_enviroment.domain.ports.repositories.application_jobs;

import uim.platform.abap_enviroment.domain.entities.application_job;
import uim.platform.abap_enviroment.domain.types;

/// Port: outgoing - application job persistence.
interface ApplicationJobRepository : ITenantRepository!(ApplicationJob, ApplicationJobId) {
  // ApplicationJob* findById(ApplicationJobId id);
  ApplicationJob[] findBySystem(SystemInstanceId systemId);
  // ApplicationJob[] findByTenant(TenantId tenantId);
  ApplicationJob[] findByStatus(SystemInstanceId systemId, JobStatus status);
  // void save(ApplicationJob job);
  // void update(ApplicationJob job);
  // void remove(ApplicationJobId id);
}
