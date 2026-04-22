/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.domain.ports.repositories.export_jobs;

// import uim.platform.auditlog.domain.types;
// import uim.platform.auditlog.domain.entities.export_job;

import uim.platform.auditlog;

mixin(ShowModule!());

/// Port for persisting export job records.
@safe:
interface ExportJobRepository : ITenantRepository!(ExportJob,ExportJobId) {

  size_t countByRequestedBy(TenantId tenantId, UserId requestedBy);
  ExportJob[] findByRequestedBy(TenantId tenantId, UserId requestedBy);
  void removeByRequestedBy(TenantId tenantId, UserId requestedBy);

  size_t countByFormat(TenantId tenantId, ExportFormat format_);
  ExportJob[] findByFormat(TenantId tenantId, ExportFormat format_);
  void removeByFormat(TenantId tenantId, ExportFormat format_);

  size_t countByStatus(TenantId tenantId, ExportStatus status);
  ExportJob[] findByStatus(TenantId tenantId, ExportStatus status);
  void removeByStatus(TenantId tenantId, ExportStatus status);

}
