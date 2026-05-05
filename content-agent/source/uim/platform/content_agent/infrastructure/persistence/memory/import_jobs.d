/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.content_agent.infrastructure.persistence.memory.import_jobs;

// import uim.platform.content_agent.domain.types;
// import uim.platform.content_agent.domain.entities.import_job;
// import uim.platform.content_agent.domain.ports.repositories.import_jobs;

// import std.algorithm : filter;
// import std.array : array;
import uim.platform.content_agent;

mixin(ShowModule!());

@safe:
class MemoryImportJobRepository : TenantRepository!(ImportJob, ImportJobId), ImportJobRepository {

  size_t countByPackage(ContentPackageId packageId) {
    return findByPackage(packageId).length;
  }

  ImportJob[] findByPackage(ContentPackageId packageId) {
    return findAll().filter!(e => e.packageId == packageId).array;
  }

  void removeByPackage(ContentPackageId packageId) {
    findByPackage(packageId).each!(e => remove(e));
  }

  size_t countByStatus(TenantId tenantId, ImportStatus status) {
    return findByStatus(tenantId, status).length;
  }

  ImportJob[] findByStatus(TenantId tenantId, ImportStatus status) {
    return findAll().filter!(e => e.tenantId == tenantId && e.status == status).array;
  }

  void removeByStatus(TenantId tenantId, ImportStatus status) {
    findByStatus(tenantId, status).each!(e => remove(e));
  }

}
