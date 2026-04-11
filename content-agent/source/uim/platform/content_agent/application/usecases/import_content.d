/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.content_agent.application.usecases.import_content;

// import uim.platform.content_agent.application.dto;
// import uim.platform.content_agent.domain.entities.import_job;
// import uim.platform.content_agent.domain.entities.content_package;
// import uim.platform.content_agent.domain.entities.content_activity;
// import uim.platform.content_agent.domain.ports.repositories.import_jobs;
// import uim.platform.content_agent.domain.ports.repositories.content_packages;
// import uim.platform.content_agent.domain.ports.repositories.content_activitys;
// import uim.platform.content_agent.domain.types;

import uim.platform.content_agent;

mixin(ShowModule!());

@safe:

/// Application service for importing content packages.
class ImportContentUseCase : UIMUseCase {
  private ImportJobRepository importRepo;
  private ContentPackageRepository packageRepo;
  private ContentActivityRepository activityRepo;

  this(ImportJobRepository importRepo, ContentPackageRepository packageRepo,
      ContentActivityRepository activityRepo) {
    this.importRepo = importRepo;
    this.packageRepo = packageRepo;
    this.activityRepo = activityRepo;
  }

  CommandResult startImport(StartImportRequest req) {
    auto pkg = packageRepo.findById(req.packageId);
    if (pkg.id.isEmpty)
      return CommandResult(false, "", "Package not found");

    ImportJob job;
    job.id = randomUUID();
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
    foreach (item; pkg.items)
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

    return CommandResult(true, id.toString, "");
  }

  ImportJob getImportJob(ImportJobId id) {
    return importRepo.findById(id);
  }

  ImportJob[] listImportJobs(TenantId tenantId) {
    return importRepo.findByTenant(tenantId);
  }

  ImportJob[] listByPackage(ContentPackageId packageId) {
    return importRepo.findByPackage(packageId);
  }

  private void recordActivity(TenantId tenantId, ActivityType actType,
      string entityId, string entityName, string desc, string by) {
    // import std.uuid : randomUUID;
    ContentActivity activity;
    activity.id = randomUUID();
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

  
}
