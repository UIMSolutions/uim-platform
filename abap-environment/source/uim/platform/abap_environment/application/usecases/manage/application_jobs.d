/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.application.usecases.manage.application_jobs;

// import uim.platform.abap_environment.application.dto;
// import uim.platform.abap_environment.domain.entities.application_job;
// import uim.platform.abap_environment.domain.ports.repositories.application_jobs;
// import uim.platform.abap_environment.domain.types;

// import std.conv : to;
// import std.uuid : randomUUID;
import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:
/// Application service for application job scheduling and management.
class ManageApplicationJobsUseCase { // TODO: UIMUseCase {
  private ApplicationJobRepository repo;

  this(ApplicationJobRepository repo) {
    this.repo = repo;
  }

  CommandResult createJob(CreateApplicationJobRequest request) {
    if (request.name.length == 0)
      return CommandResult(false, "", "Job name is required");
    if (request.jobTemplateName.length == 0)
      return CommandResult(false, "", "Job template name is required");

    if (request.systemInstanceId.isEmpty)
      return CommandResult(false, "", "System instance ID is required");

    ApplicationJob job;
    job.id = randomUUID();
    job.tenantId = request.tenantId;
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

    // import std.datetime.systime : Clock;
    job.createdAt = Clock.currStdTime();
    job.updatedAt = job.createdAt;

    repo.save(job);
    return CommandResult(true, job.id.value, "");
  }

  CommandResult updateJob(string id, UpdateApplicationJobRequest request) {
    return updateJob(ApplicationJobId(id), request);
  }

  CommandResult updateJob(ApplicationJobId id, UpdateApplicationJobRequest request) {
    if (!repo.existsById(id))
      return CommandResult(false, "", "Application job not found");

    auto job = repo.findById(id);
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

    // import std.datetime.systime : Clock;
    job.updatedAt = Clock.currStdTime();

    repo.update(job);
    return CommandResult(true, job.id.value, "");
  }

  CommandResult cancelJob(string id) {
    return cancelJob(ApplicationJobId(id));
  }

  CommandResult cancelJob(ApplicationJobId id) {
    if (!repo.existsById(id))
      return CommandResult(false, "", "Application job not found");

    auto job = repo.findById(id);
    if (job.status != JobStatus.scheduled && job.status != JobStatus.running)
      return CommandResult(false, "", "Job can only be canceled when scheduled or running");

    job.status = JobStatus.canceled;
    job.active = false;

    // import std.datetime.systime : Clock;
    job.updatedAt = Clock.currStdTime();

    repo.update(job);
    return CommandResult(true, job.id.value, "");
  }

  ApplicationJob getJob(string id) {
    return getJob(ApplicationJobId(id));
  }

  ApplicationJob getJob(ApplicationJobId id) {
    return repo.findById(id);
  }

  ApplicationJob[] listJobs(string systemId) {
    return listJobs(SystemInstanceId(systemId));
  }

  ApplicationJob[] listJobs(SystemInstanceId systemId) {
    return repo.findBySystem(systemId);
  }

  CommandResult deleteJob(string id) {
    return deleteJob(ApplicationJobId(id));
  }

  CommandResult deleteJob(ApplicationJobId id) {
    if (!repo.existsById(id))
      return CommandResult(false, "", "Application job not found");

    repo.removeById(id);
    return CommandResult(true, id.value, "");
  }
}
