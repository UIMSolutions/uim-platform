/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.job_scheduling.application.usecases.manage.jobs;

import uim.platform.job_scheduling.domain.types;
import uim.platform.job_scheduling.domain.entities.job;
import uim.platform.job_scheduling.domain.ports.repositories.jobs;
import uim.platform.job_scheduling.application.dto;

import uim.platform.service;
import std.conv : to;

alias Job = uim.platform.job_scheduling.domain.entities.job.Job;

class ManageJobsUseCase : UIMUseCase {
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
        auto id = randomUUID().to!string;

        Job j;
        j.id = id;
        j.tenantId = r.tenantId;
        j.name = r.name;
        j.description = r.description;
        j.actionUrl = r.actionUrl;
        j.httpMethod = parseHttpMethod(r.httpMethod);
        j.type = parseJobType(r.type);
        j.status = r.active ? JobStatus.active : JobStatus.inactive;
        j.active = r.active;
        j.startTime = r.startTime;
        j.endTime = r.endTime;

        import core.time : MonoTime;
        auto now = MonoTime.currTime.ticks;
        j.createdAt = now;
        j.modifiedAt = now;

        repo.save(j);
        return CommandResult(true, j.id, "");
    }

    Job get_(JobId id, TenantId tenantId) {
        return repo.findById(id, tenantId);
    }

    Job getByName(string name, TenantId tenantId) {
        return repo.findByName(name, tenantId);
    }

    Job[] list(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    Job[] search(string query, TenantId tenantId) {
        return repo.search(query, tenantId);
    }

    CommandResult update(UpdateJobRequest r) {
        auto existing = repo.findById(r.jobId, r.tenantId);
        if (existing.id.isEmpty)
            return CommandResult(false, "", "Job not found");

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
        existing.modifiedAt = MonoTime.currTime.ticks;

        repo.update(existing);
        return CommandResult(true, existing.id, "");
    }

    CommandResult remove(JobId id, TenantId tenantId) {
        auto existing = repo.findById(id, tenantId);
        if (existing.id.isEmpty)
            return CommandResult(false, "", "Job not found");

        repo.remove(id, tenantId);
        return CommandResult(true, id, "");
    }

    long count(TenantId tenantId) {
        return repo.countByTenant(tenantId);
    }

    long countActive(TenantId tenantId) {
        return repo.countActiveByTenant(tenantId);
    }

    long countInactive(TenantId tenantId) {
        return repo.countInactiveByTenant(tenantId);
    }

    private static HttpMethod parseHttpMethod(string s) {
        switch (s) {
            case "GET": return HttpMethod.get;
            case "POST": return HttpMethod.post;
            case "PUT": return HttpMethod.put;
            case "DELETE": return HttpMethod.delete_;
            case "PATCH": return HttpMethod.patch;
            default: return HttpMethod.get;
        }
    }

    private static JobType parseJobType(string s) {
        switch (s) {
            case "cloudFoundryTask": return JobType.cloudFoundryTask;
            default: return JobType.httpEndpoint;
        }
    }
}
