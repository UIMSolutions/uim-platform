/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.application.usecases.manage.exports;

// // import std.uuid;
// // import std.datetime.systime : Clock;
// 
// import uim.platform.auditlog.domain.types;
// import uim.platform.auditlog.domain.entities.export_job;
// import uim.platform.auditlog.domain.ports.repositories.export_jobs;
// import uim.platform.auditlog.domain.ports.repositories.audit_logs;
// import uim.platform.auditlog.application.dto;

import uim.platform.auditlog;

mixin(ShowModule!());
@safe:
class ManageExportsUseCase { // TODO: UIMUseCase {
  private ExportJobRepository jobs;
  private AuditLogRepository audits;

  this(ExportJobRepository jobs, AuditLogRepository audits) {
    this.jobs = jobs;
    this.audits = audits;
  }

  CommandResult createExport(CreateExportJobRequest req) {
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");

    if (req.requestedBy.isNull)
      return CommandResult(false, "", "Requester is required");

    auto now = Clock.currStdTime();
    auto job = ExportJob();
    job.initEntity(req.tenantId);

    job.requestedBy = req.requestedBy;
    job.format_ = req.format_;
    job.categories = req.categories;
    job.timeFrom = req.timeFrom;
    job.timeTo = req.timeTo;
    job.status = ExportStatus.pending;

    // Simulate immediate export completion
    auto logs = audits.search(req.tenantId, req.categories, req.timeFrom,
        req.timeTo, int.max, 0);
    job.totalRecords = logs.length;
    job.status = ExportStatus.completed;
    job.completedAt = Clock.currStdTime();
    job.downloadUrl = "/api/v1/exports/" ~ job.id.value() ~ "/download";

    jobs.save(job);
    return CommandResult(true, job.id.value(), "");
  }

  bool hasExport(TenantId tenantId, ExportJobId id) {
    return jobs.existsById(tenantId, id);
  }

  ExportJob getExport(TenantId tenantId, ExportJobId id) {
    return jobs.findById(tenantId, id);
  }

  ExportJob[] listExports(TenantId tenantId) {
    return jobs.findByTenant(tenantId);
  }

  void deleteExport(TenantId tenantId, ExportJobId id) {
    jobs.removeById(tenantId, id);
  }
}
