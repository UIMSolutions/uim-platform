module application.use_cases.manage_exports;

import std.uuid;
import std.datetime.systime : Clock;

import domain.types;
import domain.entities.export_job;
import domain.ports.export_job_repository;
import domain.ports.audit_log_repository;
import application.dto;

class ManageExportsUseCase
{
    private ExportJobRepository jobRepo;
    private AuditLogRepository auditRepo;

    this(ExportJobRepository jobRepo, AuditLogRepository auditRepo)
    {
        this.jobRepo = jobRepo;
        this.auditRepo = auditRepo;
    }

    CommandResult createExport(CreateExportJobRequest req)
    {
        if (req.tenantId.length == 0)
            return CommandResult("", "Tenant ID is required");
        if (req.requestedBy.length == 0)
            return CommandResult("", "Requester is required");

        auto now = Clock.currStdTime();
        auto job = ExportJob();
        job.id = randomUUID().toString();
        job.tenantId = req.tenantId;
        job.requestedBy = req.requestedBy;
        job.format_ = req.format_;
        job.categories = req.categories;
        job.timeFrom = req.timeFrom;
        job.timeTo = req.timeTo;
        job.status = ExportStatus.pending;
        job.createdAt = now;

        // Simulate immediate export completion
        auto logs = auditRepo.search(req.tenantId, req.categories,
            req.timeFrom, req.timeTo, int.max, 0);
        job.totalRecords = cast(long) logs.length;
        job.status = ExportStatus.completed;
        job.completedAt = Clock.currStdTime();
        job.downloadUrl = "/api/v1/exports/" ~ job.id ~ "/download";

        jobRepo.save(job);
        return CommandResult(job.id, "");
    }

    ExportJob* getExport(ExportJobId id, TenantId tenantId)
    {
        return jobRepo.findById(id, tenantId);
    }

    ExportJob[] listExports(TenantId tenantId)
    {
        return jobRepo.findByTenant(tenantId);
    }

    void deleteExport(ExportJobId id, TenantId tenantId)
    {
        jobRepo.remove(id, tenantId);
    }
}
