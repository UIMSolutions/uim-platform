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

  size_t countByRequestedBy(TenantId tenantId, UserId requestedBy) {
    return findByRequestedBy(tenantId, requestedBy).length;
  }
  ExportJob[] filterByRequestedBy(ExportJob[] jobs, UserId requestedBy) {
    return jobs.filter!(e => e.requestedBy == requestedBy).array;
  }
  ExportJob[] findByRequestedBy(TenantId tenantId, UserId requestedBy) {
    return filterByRequestedBy(findByTenant(tenantId), requestedBy);
  }
  void removeByRequestedBy(TenantId tenantId, UserId requestedBy) {
    findByRequestedBy(tenantId, requestedBy).each!(e => remove(e));
  }


  size_t countByFormat(TenantId tenantId, ExportFormat format) {
    return findByFormat(tenantId, format).length;
  }
  ExportJob[] filterByFormat(ExportJob[] logs, ExportFormat format) {
    return logs.filter!(e => e.format_ == format).array;
  }
  ExportJob[] findByFormat(TenantId tenantId, ExportFormat format) {
    return filterByFormat(findByTenant(tenantId), format);
  }
  void removeByFormat(TenantId tenantId, ExportFormat format) {
    findByFormat(tenantId, format).each!(e => remove(e));
  }

  size_t countByStatus(TenantId tenantId, ExportStatus status) {
    return findByStatus(tenantId, status).length;
  }
  ExportJob[] filterByStatus(ExportJob[] logs, ExportStatus status) {
    return logs.filter!(e => e.status == status).array;
  }
  ExportJob[] findByStatus(TenantId tenantId, ExportStatus status) {
    return filterByStatus(findByTenant(tenantId), status);
  }
  void removeByStatus(TenantId tenantId, ExportStatus status) {
    findByStatus(tenantId, status).each!(e => remove(e));
  }
}
