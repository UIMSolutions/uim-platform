/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.application.usecases.manage.application_jobs;

import uim.platform.abap_environment;

// mixin(ShowModule!());

@safe:
/// Application service for application job scheduling and management.
class ManageApplicationJobsUseCase {
  protected IApplicationJobRepository jobs;

  this(IApplicationJobRepository jobs) {
    this.jobs = jobs;
  }

  UsecaseResult createApplicationJob(CreateApplicationJobRequest request) {
    if (request.name.isEmpty)
      return UsecaseResult(false, "", "Job name is required");
      
    if (request.jobTemplateName.isEmpty)
      return UsecaseResult(false, "", "Job template name is required");

    if (request.systemInstanceId.isEmpty)
      return UsecaseResult(false, "", "System instance ID is required");

    auto job = ApplicationJob(request.tenantId);
    job.systemInstanceId = request.systemInstanceId;
    job.name = request.name;
    job.description = request.description;
    job.jobTemplateName = request.jobTemplateName;
    job.frequency = request.frequency.to!JobFrequency;
    job.scheduledAt = request.scheduledAt;
    job.cronExpression = request.cronExpression;
    job.active = true;
    job.status = JobStatus.scheduled;
    job.jobParameters = request.jobParameters;

    jobs.save(job);
    return UsecaseResult(true, job.id.value, "");
  }

  UsecaseResult updateApplicationJob(UpdateApplicationJobRequest request) {
    auto job = jobs.findById(request.tenantId, request.applicationJobId);
    if (job.isNull)
      return UsecaseResult(false, "", "Application job not found");

    if (request.description.length > 0)
      job.description = request.description;
    if (request.frequency.length > 0)
      job.frequency = request.frequency.to!JobFrequency;
    if (request.scheduledAt > 0)
      job.scheduledAt = request.scheduledAt;
    if (request.cronExpression.length > 0)
      job.cronExpression = request.cronExpression;
    job.active = request.active;
    if (request.jobParameters.length > 0)
      job.jobParameters = request.jobParameters;

    
    job.updatedAt = currentTimestamp();

    jobs.update(job);
    return UsecaseResult(true, job.id.value, "");
  }

  UsecaseResult cancelApplicationJob(TenantId tenantId, ApplicationJobId id) {
    auto job = jobs.findById(tenantId, id);
    if (job.isNull)
      return UsecaseResult(false, "", "Application job not found");

    if (job.status != JobStatus.scheduled && job.status != JobStatus.running)
      return UsecaseResult(false, "", "Job can only be canceled when scheduled or running");

    job.status = JobStatus.canceled;
    job.active = false;

    
    job.updatedAt = currentTimestamp();

    jobs.update(job);
    return UsecaseResult(true, job.id.value, "");
  }

  ApplicationJob getApplicationJob(TenantId tenantId, ApplicationJobId id) {
    return jobs.findById(tenantId, id);
  }

  ApplicationJob[] listApplicationJobs(TenantId tenantId, SystemInstanceId systemId) {
    return jobs.findBySystem(tenantId, systemId);
  }

  UsecaseResult deleteApplicationJob(TenantId tenantId, ApplicationJobId id) {
    auto job = jobs.findById(tenantId, id);
    if (job.isNull)
      return UsecaseResult(false, "", "Application job not found");

    jobs.remove(job);
    return UsecaseResult(true, job.id.value, "");
  }
}

///
unittest {
//    auto applicationJobRepository = new ApplicationJobRepository();
//    auto usecase = new ManageApplicationJobsUseCase(applicationJobRepository);
//    auto tenantId = TenantId("test-tenant");
//
}
