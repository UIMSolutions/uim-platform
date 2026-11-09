/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.ports.usecases.manage_exports;

import uim.platform.auditlog;

mixin(ShowModule!());

@safe:

/// Driving port: audit log export jobs.
interface IManageExportsUseCase {
  UsecaseResult createExport(CreateExportJobRequest req);
  bool hasExport(TenantId tenantId, ExportJobId id);
  ExportJob getExport(TenantId tenantId, ExportJobId id);
  ExportJob[] listExports(TenantId tenantId);
  UsecaseResult deleteExport(TenantId tenantId, ExportJobId id);
  /// Render the export content (JSON array or CSV) for a completed job.
  string renderExport(TenantId tenantId, ExportJobId id);
}
