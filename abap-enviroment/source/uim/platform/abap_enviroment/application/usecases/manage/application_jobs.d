/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_enviroment.application.usecases.manage.application_jobs;

import uim.platform.abap_enviroment.application.dto;
import uim.platform.abap_enviroment.domain.entities.application_job;
import uim.platform.abap_enviroment.domain.ports.repositories.application_jobs;
import uim.platform.abap_enviroment.domain.types;

// import std.conv : to;
// import std.uuid : randomUUID;

/// Application service for application job scheduling and management.
class ManageApplicationJobsUseCase : UIMUseCase {
  private ApplicationJobRepository repo;

  this(ApplicationJobRepository repo) {
    this.repo = repo;
  }

  CommandResult createJob(CreateApplicationJobRequest req) {
    if (req.name.length == 0)
      return CommandResult("", "Job name is required");
    if (req.jobTemplateName.length == 0)
      return CommandResult("", "Job template name is required");

    if (req.systemInstanceid.isEmpty)
      return CommandResult("", "System instance ID is required");

    auto id = randomUUID().toString();
    ApplicationJob job;
    job.id = randomUUID();
    job.tenantId = req.tenantId;
    job.systemInstanceId = req.systemInstanceId;
    job.name = req.name;
    job.description = req.description;
    job.jobTemplateName = req.jobTemplateName;
    job.frequency = parseFrequency(req.frequency);
    job.scheduledAt = req.scheduledAt;
    job.cronExpression = req.cronExpression;
    job.active = true;
    job.status = JobStatus.scheduled;
    job.jobParameters = req.jobParameters;

    // import std.datetime.systime : Clock;
    job.createdAt = Clock.currStdTime();
    job.updatedAt = job.createdAt;

    repo.save(job);
    return CommandResult(id, "");
  }

  CommandResult updateJob(ApplicationJobId id, UpdateApplicationJobRequest req) {
    auto job = repo.findById(id);
    if (job is null)
      return CommandResult("", "Application job not found");

    if (req.description.length > 0)
      job.description = req.description;
    if (req.frequency.length > 0)
      job.frequency = parseFrequency(req.frequency);
    if (req.scheduledAt > 0)
      job.scheduledAt = req.scheduledAt;
    if (req.cronExpression.length > 0)
      job.cronExpression = req.cronExpression;
    job.active = req.active;
    if (req.jobParameters.length > 0)
      job.jobParameters = req.jobParameters;

    // import std.datetime.systime : Clock;
    job.updatedAt = Clock.currStdTime();

    repo.update(*job);
    return CommandResult(id, "");
  }

  CommandResult cancelJob(ApplicationJobId id) {
    auto job = repo.findById(id);
    if (job is null)
      return CommandResult("", "Application job not found");

    if (job.status != JobStatus.scheduled && job.status != JobStatus.running)
      return CommandResult("", "Job can only be canceled when scheduled or running");

    job.status = JobStatus.canceled;
    job.active = false;

    // import std.datetime.systime : Clock;
    job.updatedAt = Clock.currStdTime();

    repo.update(*job);
    return CommandResult(id, "");
  }

  ApplicationJob* getJob(ApplicationJobId id) {
    return repo.findById(id);
  }

  ApplicationJob[] listJobs(SystemInstanceId systemId) {
    return repo.findBySystem(systemId);
  }

  CommandResult deleteJob(ApplicationJobId id) {
    auto job = repo.findById(id);
    if (job is null)
      return CommandResult("", "Application job not found");

    repo.remove(id);
    return CommandResult(id, "");
  }
}

private JobFrequency parseFrequency(string s) {
  switch (s) {
  case "once":
    return JobFrequency.once;
  case "hourly":
    return JobFrequency.hourly;
  case "daily":
    return JobFrequency.daily;
  case "weekly":
    return JobFrequency.weekly;
  case "monthly":
    return JobFrequency.monthly;
  default:
    return JobFrequency.once;
  }
}
