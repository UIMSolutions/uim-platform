/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.buildcode.application.usecases.manage.build_jobs;

import uim.platform.buildcode;
import std.conv     : to;
import std.datetime : Clock, SysTime;

mixin(ShowModule!());

@safe:

class ManageBuildJobsUseCase {
  private BuildJobRepository   _repo;
  private PipelineRepository   _pipelineRepo;

  this(BuildJobRepository repo, PipelineRepository pipelineRepo) {
    _repo         = repo;
    _pipelineRepo = pipelineRepo;
  }

  CommandResult trigger(string tenantId, TriggerBuildRequest req) {
    auto pipeline = _pipelineRepo.findById(tenantId, PipelineId(req.pipelineId));
    if (pipeline.isNull)
      return CommandResult(false, "", "Pipeline not found");
    if (!pipeline.isActive)
      return CommandResult(false, "", "Pipeline is not active");

    BuildJob job;
    job.initEntity(tenantId);
    job.pipelineId   = PipelineId(req.pipelineId);
    job.projectId    = pipeline.projectId;
    job.commitSha    = req.commitSha;
    job.branch       = req.branch.length > 0 ? req.branch : pipeline.branch;
    job.status       = JobStatus.queued;
    job.startedAtMs  = 0;
    job.finishedAtMs = 0;
    job.triggeredBy  = req.triggeredBy;

    _repo.save(job);
    return CommandResult(true, job.id.value, "");
  }

  BuildJob getById(string tenantId, string id) {
    return _repo.findById(tenantId, BuildJobId(id));
  }

  BuildJob[] list(string tenantId) {
    return _repo.findByTenant(tenantId);
  }

  BuildJob[] listByPipeline(string tenantId, string pipelineId) {
    return _repo.findByPipeline(tenantId, pipelineId);
  }

  BuildJob[] listByProject(string tenantId, string projectId) {
    return _repo.findByProject(tenantId, projectId);
  }

  CommandResult updateStatus(string tenantId, string id, string statusStr) {
    auto job = _repo.findById(tenantId, BuildJobId(id));
    if (job.isNull) return CommandResult(false, "", "Build job not found");
    static foreach (member; __traits(allMembers, JobStatus)) {
      if (statusStr == mixin("JobStatus." ~ member ~ ".to!string"))
        job.status = mixin("JobStatus." ~ member);
    }
    _repo.update(job);
    return CommandResult(true, id, "");
  }
}
