/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.content_agent.application.usecases.export_content;

// import uim.platform.content_agent.domain.entities.export_job;
// import uim.platform.content_agent.domain.entities.content_package;
// import uim.platform.content_agent.domain.entities.content_activity;
// import uim.platform.content_agent.domain.ports.repositories.export_jobs;
// import uim.platform.content_agent.domain.ports.repositories.content_packages;
// import uim.platform.content_agent.domain.ports.repositories.content_activitys;


import uim.platform.content_agent;

// mixin(ShowModule!());

@safe:
/// Application service for exporting content packages.
class ExportContentUseCase { // TODO: UIMUseCase {
  private ExportJobRepository exportRepo;
  private ContentPackageRepository packageRepo;
  private ContentActivityRepository activityRepo;

  this(ExportJobRepository exportRepo, ContentPackageRepository packageRepo,
    ContentActivityRepository activityRepo) {
    this.exportRepo = exportRepo;
    this.packageRepo = packageRepo;
    this.activityRepo = activityRepo;
  }

  CommandResult startExport(StartExportRequest req) {
    if (!packageRepo.existsById(req.packageId))
      return CommandResult(false, "", "Package not found");

    auto pkg = packageRepo.findById(req.packageId);
    if (pkg.status != PackageStatus.assembled)
      return CommandResult(false, "", "Package must be assembled before export");

    ExportJob job;
    job.initEntity(req.tenantId, req.startedBy);
    
    job.packageId = req.packageId;
    job.transportRequestId = req.transportRequestId;
    job.queueId = req.queueId;
    job.status = ExportStatus.assembling;
    job.startedAt = job.createdAt;

    exportRepo.save(job);

    // Simulate export processing: assemble -> package -> upload -> complete
    job.status = ExportStatus.packaging;
    job.exportedSizeBytes = pkg.packageSizeBytes;
    job.exportedFilePath = "/exports/" ~ pkg.name ~ "." ~ pkg.format.to!string;
    exportRepo.update(job);

    job.status = ExportStatus.completed;
    job.completedAt = job.updatedAt;
    exportRepo.update(job);

    // Update package status
    pkg.status = PackageStatus.exported;
    pkg.updatedAt = pkg.updatedAt;
    packageRepo.update(pkg);

    recordActivity(req.tenantId, ActivityType.exportCompleted, id, pkg.name,
      "Export completed for package: " ~ pkg.name, req.startedBy);

    return CommandResult(true, id.value, "");
  }

  ExportJob getExportJob(TenantId tenantId, ExportJobId id) {
    return exportRepo.findById(tenantId, id);
  }

  ExportJob[] listExportJobs(TenantId tenantId) {
    return exportRepo.findByTenant(tenantId);
  }

  ExportJob[] listByPackage(TenantId tenantId, ContentPackageId packageId) {
    return exportRepo.findByPackage(tenantId, packageId);
  }

  private void recordActivity(TenantId tenantId, ActivityType actType,
    string entityId, string entityName, string desc, string by) {
    ContentActivity activity;
    activity.initEntity(tenantId);

    activity.activityType = actType;
    activity.severity = ActivitySeverity.info;
    activity.entityId = entityId;
    activity.entityName = entityName;
    activity.description = desc;
    activity.performedBy = by;

    activity.timestamp = activity.createdAt;
    activityRepo.save(activity);
  }

}
