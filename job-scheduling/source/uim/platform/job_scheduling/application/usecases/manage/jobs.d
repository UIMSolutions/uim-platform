/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.job_scheduling.application.usecases.manage.jobs;

// import uim.platform.job_scheduling.domain.types;
// import uim.platform.job_scheduling.domain.entities.job;
// import uim.platform.job_scheduling.domain.ports.repositories.jobs;
// import uim.platform.job_scheduling.application.dto;

// import uim.platform.service;
// import std.conv : to;

// alias Job = uim.platform.job_scheduling.domain.entities.job.Job;
import uim.platform.job_scheduling;

mixin(ShowModule!());

@safe:
class ManageJobsUseCase { // TODO: UIMUseCase {
    private JobRepository repo;

    this(JobRepository repo) {
        this.repo = repo;
    }

    CommandResult create(CreateJobRequest r) {
        if (r.name.length == 0)
            return CommandResult(false, "", "Job name is required");
        if (r.actionUrl.length == 0 && r.type != "cloudFoundryTask")
            return CommandResult(false, "", "Action URL is required for HTTP jobs");

        import std.uuid : randomUUID;

        auto id = randomUUID();

        Job job;
        job.id = id;
        job.tenantId = r.tenantId;
        job.name = r.name;
        job.description = r.description;
        job.actionUrl = r.actionUrl;
        job.httpMethod = parseHttpMethod(r.httpMethod);
        job.type = parseJobType(r.type);
        job.status = r.active ? JobStatus.active : JobStatus.inactive;
        job.active = r.active;
        job.startTime = r.startTime;
        job.endTime = r.endTime;

        import core.time : MonoTime;

        auto now = MonoTime.currTime.ticks;
        job.createdAt = now;
        job.updatedAt = now;

        repo.save(job);
        return CommandResult(true, job.id.toString, "");
    }

    Job getById(TenantId tenantId, JobId id) {
        return repo.findById(tenantId, id);
    }

    Job getByName(TenantId tenantId, string name) {
        return repo.findByName(tenantId, name);
    }

    Job[] list(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    Job[] search(TenantId tenantId, string query) {
        return repo.search(tenantId, query);
    }

    CommandResult update(UpdateJobRequest r) {
        if (!repo.existsById(r.tenantId, r.jobId))
            return CommandResult(false, "", "Job not found");

        auto existing = repo.findById(r.tenantId, r.jobId);
        if (r.name.length > 0)
            existing.name = r.name;
        if (r.description.length > 0)
            existing.description = r.description;
        if (r.actionUrl.length > 0)
            existing.actionUrl = r.actionUrl;
        if (r.httpMethod.length > 0)
            existing.httpMethod = parseHttpMethod(r.httpMethod);
        existing.active = r.active;
        existing.status = r.active ? JobStatus.active : JobStatus.inactive;
        existing.startTime = r.startTime;
        existing.endTime = r.endTime;

        import core.time : MonoTime;

        existing.updatedAt = MonoTime.currTime.ticks;

        repo.update(existing);
        return CommandResult(true, existing.id.toString, "");
    }

    CommandResult remove(TenantId tenantId, JobId id) {
        if (!repo.existsById(tenantId, id))
            return CommandResult(false, "", "Job not found");

        repo.remove(tenantId, id);
        return CommandResult(true, id.toString, "");
    }

    size_t count(TenantId tenantId) {
        return repo.countByTenant(tenantId);
    }

    size_t countActive(TenantId tenantId) {
        return repo.countActiveByTenant(tenantId);
    }

    size_t countInactive(TenantId tenantId) {
        return repo.countInactiveByTenant(tenantId);
    }

    private static HttpMethod parseHttpMethod(string method) {
        switch (method) {
        case "GET":
            return HttpMethod.get;
        case "POST":
            return HttpMethod.post;
        case "PUT":
            return HttpMethod.put;
        case "DELETE":
            return HttpMethod.delete_;
        case "PATCH":
            return HttpMethod.patch;
        default:
            return HttpMethod.get;
        }
    }

    private static JobType parseJobType(string type) {
        switch (type) {
        case "cloudFoundryTask":
            return JobType.cloudFoundryTask;
        default:
            return JobType.httpEndpoint;
        }
    }
}
