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
interface ExportJobRepository {
  ExportJob[] findByTenant(TenantId tenantId);

  bool existsById(TenantId tenantId, ExportJobId id);
  ExportJob findById(TenantId tenantId, ExportJobId id);

  void save(ExportJob job);
  void update(ExportJob job);
  void remove(TenantId tenantId, ExportJobId id);
}
