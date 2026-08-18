/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.job_scheduling.application.usecases.manage.jobs;

// import uim.platform.job_scheduling.domain.entities.job;
// import uim.platform.job_scheduling.domain.ports.repositories.jobs;



// alias Job = uim.platform.job_scheduling.domain.entities.job.Job;
import uim.platform.job_scheduling;

mixin(ShowModule!());

@safe:
class ManageJobsUseCase {
    private IJobRepository repo;

    this(IJobRepository repo) {
        this.repo = repo;
    }

    UsecaseResult createJob(CreateJobRequest r) {
        if (r.name.isEmpty)
            return UsecaseResult(false, "", "Job name is required");
        if (r.actionUrl.length == 0 && r.type != "cloudFoundryTask")
            return UsecaseResult(false, "", "Action URL is required for HTTP jobs");

        auto job = Job(r.tenantId, r.jobId.isNull ? JobId(createId()) : r.jobId); // , r.createdBy);
        job.name = r.name;
        job.description = r.description;
        job.actionUrl = r.actionUrl;
        job.httpMethod = r.httpMethod.to!HttpMethod;
        job.type = parseJobType(r.type);
        job.status = r.active ? JobStatus.active : JobStatus.inactive;
        job.active = r.active;
        job.startTime = r.startTime;
        job.endTime = r.endTime;

        repo.save(job);
        return UsecaseResult(true, job.id.value, "");
    }

    Job getJob(TenantId tenantId, JobId id) {
        return repo.findById(tenantId, id);
    }

    Job getJob(TenantId tenantId, string name) {
        return repo.findByName(tenantId, name);
    }

    Job[] listJobs(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    Job[] searchJobs(TenantId tenantId, string query) {
        return repo.search(tenantId, query);
    }

    UsecaseResult updateJob(UpdateJobRequest r) {
        auto existing = repo.findById(r.tenantId, r.jobId);
        if (existing.isNull)
            return UsecaseResult(false, "", "Job not found");

        if (r.name.length > 0)
            existing.name = r.name;
        if (r.description.length > 0)
            existing.description = r.description;
        if (r.actionUrl.length > 0)
            existing.actionUrl = r.actionUrl;
        if (r.httpMethod.length > 0)
            existing.httpMethod = r.httpMethod.to!HttpMethod;
        existing.active = r.active;
        existing.status = r.active ? JobStatus.active : JobStatus.inactive;
        existing.startTime = r.startTime;
        existing.endTime = r.endTime;

        existing.updatedAt = currentTimestamp;

        repo.update(existing);
        return UsecaseResult(true, existing.id.value, "");
    }

    UsecaseResult deleteJob(TenantId tenantId, JobId id) {
        auto entity = repo.findById(tenantId, id);
        if (entity.isNull)
            return UsecaseResult(false, "", "Job not found");

        repo.remove(entity);
        return UsecaseResult(true, entity.id.value, "");
    }

    size_t countJobs(TenantId tenantId) {
        return repo.countByTenant(tenantId);
    }

    size_t countActiveJobs(TenantId tenantId) {
        return repo.countActiveByTenant(tenantId);
    }

    size_t countInactiveJobs(TenantId tenantId) {
        return repo.countInactiveByTenant(tenantId);
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

///
unittest {
//     auto repo = new JobRepository();
//     auto usecase = new ManageJobsUseCase(repo);
//     auto tenantId = TenantId("test-tenant");
// 
//     // Test list
//     auto items = usecase.listJobs(tenantId);
//     assert(items !is null);
// 
}
