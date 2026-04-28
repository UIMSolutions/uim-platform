/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.infrastructure.persistence.memory.export_;

// import uim.platform.auditlog.domain.types;
// import uim.platform.auditlog.domain.entities.export_job;
// import uim.platform.auditlog.domain.ports.repositories.export_jobs;

// import std.algorithm : filter;
// import std.array : array;

import uim.platform.auditlog;

mixin(ShowModule!());

@safe:
class MemoryExportJobRepository : TenantRepository!(ExportJob, ExportJobId), ExportJobRepository {

  size_t countByPackage(ContentPackageId packageId) {
    return findByPackage(packageId).length;
  }
  ExportJob[] filterByPackage(ExportJob[] logs, ContentPackageId packageId) {
    return logs.filter!(e => e.packageId == packageId).array;
  }
  ExportJob[] findByPackage(ContentPackageId packageId) {
    return findAll().filter!(e => e.packageId == packageId).array;
  }
  void removeByPackage(ContentPackageId packageId) {
    findByPackage(packageId).each!(e => remove(e));
  }

  size_t countByPackage(ContentPackageId packageId) {
    return findByPackage(packageId).length;
  }
  ExportJob[] filterByPackage(ExportJob[] logs, ContentPackageId packageId) {
    return logs.filter!(e => e.packageId == packageId).array;
  }
  ExportJob[] findByPackage(ContentPackageId packageId) {
    return findAll().filter!(e => e.packageId == packageId).array;
  }
  void removeByPackage(ContentPackageId packageId) {
    findByPackage(packageId).each!(e => remove(e));
  }
}
