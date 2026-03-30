module application.use_cases.manage_cleansing_jobs;

import std.uuid;
import std.datetime.systime : Clock;

import domain.types;
import domain.entities.cleansing_job;
import domain.ports.cleansing_job_repository;
import application.dto;

class ManageCleansingJobsUseCase
{
    private CleansingJobRepository repo;

    this(CleansingJobRepository repo)
    {
        this.repo = repo;
    }

    CommandResult create(CreateCleansingJobRequest req)
    {
        if (req.tenantId.length == 0)
            return CommandResult("", "Tenant ID is required");
        if (req.datasetId.length == 0)
            return CommandResult("", "Dataset ID is required");

        auto job = CleansingJob();
        job.id = randomUUID().toString();
        job.tenantId = req.tenantId;
        job.datasetId = req.datasetId;
        job.requestedBy = req.requestedBy;
        job.status = JobStatus.pending;
        job.ruleIds = req.ruleIds;
        job.createdAt = Clock.currStdTime();

        repo.save(job);
        return CommandResult(job.id, "");
    }

    CleansingJob* getById(CleansingJobId id, TenantId tenantId)
    {
        return repo.findById(id, tenantId);
    }

    CleansingJob[] listByTenant(TenantId tenantId)
    {
        return repo.findByTenant(tenantId);
    }

    CleansingJob[] listByDataset(TenantId tenantId, DatasetId datasetId)
    {
        return repo.findByDataset(tenantId, datasetId);
    }

    CleansingJob[] listByStatus(TenantId tenantId, JobStatus status)
    {
        return repo.findByStatus(tenantId, status);
    }
}
