module uim.platform.content_agent.application.usecases.export_content;

import uim.platform.content_agent.application.dto;
import uim.platform.content_agent.domain.entities.export_job;
import uim.platform.content_agent.domain.entities.content_package;
import uim.platform.content_agent.domain.entities.content_activity;
import uim.platform.content_agent.domain.ports.export_job_repository;
import uim.platform.content_agent.domain.ports.content_package_repository;
import uim.platform.content_agent.domain.ports.content_activity_repository;
import uim.platform.content_agent.domain.types;

// import std.conv : to;

/// Application service for exporting content packages.
class ExportContentUseCase
{
    private ExportJobRepository exportRepo;
    private ContentPackageRepository packageRepo;
    private ContentActivityRepository activityRepo;

    this(ExportJobRepository exportRepo,
         ContentPackageRepository packageRepo,
         ContentActivityRepository activityRepo)
    {
        this.exportRepo = exportRepo;
        this.packageRepo = packageRepo;
        this.activityRepo = activityRepo;
    }

    CommandResult startExport(StartExportRequest req)
    {
        auto pkg = packageRepo.findById(req.packageId);
        if (pkg.id.length == 0)
            return CommandResult(false, "", "Package not found");

        if (pkg.status != PackageStatus.assembled)
            return CommandResult(false, "", "Package must be assembled before export");

        // import std.uuid : randomUUID;
        auto id = randomUUID().toString();

        ExportJob job;
        job.id = id;
        job.tenantId = req.tenantId;
        job.packageId = req.packageId;
        job.transportRequestId = req.transportRequestId;
        job.queueId = req.queueId;
        job.status = ExportStatus.assembling;
        job.createdBy = req.startedBy;
        job.startedAt = clockSeconds();

        exportRepo.save(job);

        // Simulate export processing: assemble -> package -> upload -> complete
        job.status = ExportStatus.packaging;
        job.exportedSizeBytes = pkg.packageSizeBytes;
        job.exportedFilePath = "/exports/" ~ pkg.name ~ "." ~ pkg.format.to!string;
        exportRepo.update(job);

        job.status = ExportStatus.completed;
        job.completedAt = clockSeconds();
        exportRepo.update(job);

        // Update package status
        pkg.status = PackageStatus.exported;
        pkg.updatedAt = clockSeconds();
        packageRepo.update(pkg);

        recordActivity(req.tenantId, ActivityType.exportCompleted, id, pkg.name,
            "Export completed for package: " ~ pkg.name, req.startedBy);

        return CommandResult(true, id, "");
    }

    ExportJob getExportJob(ExportJobId id)
    {
        return exportRepo.findById(id);
    }

    ExportJob[] listExportJobs(TenantId tenantId)
    {
        return exportRepo.findByTenant(tenantId);
    }

    ExportJob[] listByPackage(ContentPackageId packageId)
    {
        return exportRepo.findByPackage(packageId);
    }

    private void recordActivity(TenantId tenantId, ActivityType actType,
        string entityId, string entityName, string desc, string by)
    {
        // import std.uuid : randomUUID;
        ContentActivity activity;
        activity.id = randomUUID().toString();
        activity.tenantId = tenantId;
        activity.activityType = actType;
        activity.severity = ActivitySeverity.info;
        activity.entityId = entityId;
        activity.entityName = entityName;
        activity.description = desc;
        activity.performedBy = by;
        activity.timestamp = clockSeconds();
        activityRepo.save(activity);
    }

    private static long clockSeconds()
    {
        // import std.datetime.systime : Clock;
        return Clock.currTime().toUnixTime();
    }
}
