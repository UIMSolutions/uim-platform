/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.domain.ports.usecases.application_jobs;

import uim.platform.abap_environment;

// mixin(ShowModule!());

@safe:
/// Application service for application job scheduling and management.
interface IManageApplicationJobsUseCase { 

  CommandResult createApplicationJob(CreateApplicationJobRequest request);
  CommandResult updateApplicationJob(UpdateApplicationJobRequest request);
  CommandResult cancelApplicationJob(TenantId tenantId, ApplicationJobId id);
  ApplicationJob getApplicationJob(TenantId tenantId, ApplicationJobId id);
  ApplicationJob[] listApplicationJobs(TenantId tenantId, SystemInstanceId systemId);
  CommandResult deleteApplicationJob(TenantId tenantId, ApplicationJobId id);
  
}
