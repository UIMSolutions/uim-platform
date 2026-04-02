module application.usecases.import_content;

import uim.platform.content_agent.application.dto;
import domain.entities.import_job;
import domain.entities.content_package;
import domain.entities.content_activity;
import domain.ports.import_job_repository;
import domain.ports.content_package_repository;
import domain.ports.content_activity_repository;
import domain.types;

import std.conv : to;

/// Application service for importing content packages.
class ImportContentUseCase
{
    private ImportJobRepository importRepo;
    private ContentPackageRepository packageRepo;
    private ContentActivityRepository activityRepo;

    this(ImportJobRepository importRepo,
         ContentPackageRepository packageRepo,
         ContentActivityRepository activityRepo)
    {
        this.importRepo = importRepo;
        this.packageRepo = packageRepo;
        this.activityRepo = activityRepo;
    }

    CommandResult startImport(StartImportRequest req)
    {
        auto pkg = packageRepo.findById(req.packageId);
        if (pkg.id.length == 0)
            return CommandResult(false, "", "Package not found");

        import std.uuid : randomUUID;
        auto id = randomUUID().toString();

        ImportJob job;
        job.id = id;
        job.tenantId = req.tenantId;
        job.packageId = req.packageId;
        job.transportRequestId = req.transportRequestId;
        job.sourceFilePath = req.sourceFilePath;
        job.status = ImportStatus.downloading;
        job.createdBy = req.startedBy;
        job.startedAt = clockSeconds();

        importRepo.save(job);

        // Simulate import processing: download -> validate -> deploy -> complete
        job.status = ImportStatus.validating;
        importRepo.update(job);

        job.status = ImportStatus.deploying;
        importRepo.update(job);

        // Record deployed items from package
        string[] deployed;
        foreach (ref item; pkg.items)
            deployed ~= item.name;
        job.deployedItems = deployed;
        job.importedSizeBytes = pkg.packageSizeBytes;
        job.status = ImportStatus.completed;
        job.completedAt = clockSeconds();
        importRepo.update(job);

        // Update package status
        pkg.status = PackageStatus.delivered;
        pkg.updatedAt = clockSeconds();
        packageRepo.update(pkg);

        recordActivity(req.tenantId, ActivityType.importCompleted, id, pkg.name,
            "Import completed for package: " ~ pkg.name, req.startedBy);

        return CommandResult(true, id, "");
    }

    ImportJob getImportJob(ImportJobId id)
    {
        return importRepo.findById(id);
    }

    ImportJob[] listImportJobs(TenantId tenantId)
    {
        return importRepo.findByTenant(tenantId);
    }

    ImportJob[] listByPackage(ContentPackageId packageId)
    {
        return importRepo.findByPackage(packageId);
    }

    private void recordActivity(TenantId tenantId, ActivityType actType,
        string entityId, string entityName, string desc, string by)
    {
        import std.uuid : randomUUID;
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
        import std.datetime.systime : Clock;
        return Clock.currTime().toUnixTime();
    }
}
