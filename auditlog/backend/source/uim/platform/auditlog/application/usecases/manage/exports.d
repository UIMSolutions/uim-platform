/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.application.usecases.manage.exports;

import uim.platform.auditlog;

mixin(ShowModule!());

@safe:

/// Interactor: export jobs. Exports are executed synchronously (the in-memory
/// data volume is small); the content is rendered on download.
class ManageExportsUseCase : IManageExportsUseCase {
  protected IExportJobRepository jobs;
  protected IAuditLogRepository audits;
  protected IAuditEventPublisher publisher;

  this(IExportJobRepository jobs, IAuditLogRepository audits, IAuditEventPublisher publisher = null) {
    this.jobs = jobs;
    this.audits = audits;
    this.publisher = publisher;
  }

  UsecaseResult createExport(CreateExportJobRequest req) {
    if (req.tenantId.isEmpty)
      return UsecaseResult(false, "", "Tenant ID is required", 400);
    if (req.requestedBy.isNull)
      return UsecaseResult(false, "", "Requester is required", 400);
    if (TimeRange(req.timeFrom, req.timeTo).isInverted)
      return UsecaseResult(false, "", "timeFrom must be before timeTo", 400);

    auto job = ExportJob(req.tenantId);
    job.requestedBy = req.requestedBy;
    job.format_ = req.format_;
    job.categories = req.categories;
    job.timeFrom = req.timeFrom;
    job.timeTo = req.timeTo;

    auto logs = selectEntries(job);
    job.totalRecords = logs.length;
    job.status = ExportStatus.completed;
    job.completedAt = currentTimestamp();
    job.downloadUrl = "/api/v1/exports/" ~ job.id.value ~ "/download";

    jobs.save(job);
    if (publisher !is null)
      publisher.publish(AuditTopics.exportCompleted, job.toJson);
    return UsecaseResult(true, job.id.value, "Export completed");
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

  UsecaseResult deleteExport(TenantId tenantId, ExportJobId id) {
    auto job = jobs.findById(tenantId, id);
    if (job.isNull)
      return UsecaseResult(false, "", "Export job not found", 404);

    jobs.remove(job);
    return UsecaseResult(true, job.id.value, "Export job deleted");
  }

  string renderExport(TenantId tenantId, ExportJobId id) {
    auto job = jobs.findById(tenantId, id);
    if (job.isNull)
      return null;

    auto entries = selectEntries(job);
    if (job.format_ == ExportFormat.json)
      return entries.map!(e => e.toJson).array.toJson.toPrettyString;

    string csv = "id,timestamp,category,severity,action,outcome,userId,userName,objectType,objectId,message\n";
    foreach (e; entries) {
      csv ~= [e.id.value, e.timestamp.to!string, e.category.to!string, e.severity.to!string,
        e.action.to!string, e.outcome.to!string, e.userId.value, e.userName,
        e.objectType, e.objectId, e.message].map!csvField.join(",") ~ "\n";
    }
    return csv;
  }

  protected AuditLogEntry[] selectEntries(const ExportJob job) {
    return audits.search(job.tenantId, job.categories.dup, job.timeFrom, job.timeTo, int.max, 0);
  }

  private static string csvField(string value) {
    if (value.canFind(',') || value.canFind('"') || value.canFind('\n'))
      return '"' ~ value.replace("\"", "\"\"") ~ '"';
    return value;
  }
}
///
unittest {
  mixin(ShowTest!("ManageExportsUseCase"));

  auto logs = new AuditLogRepository();
  auto tenant = TenantId("t1");
  auto e = AuditLogEntry(tenant);
  e.message = "hello, world";
  e.timestamp = e.createdAt;
  logs.save(e);

  auto uc = new ManageExportsUseCase(new ExportJobRepository(), logs);
  CreateExportJobRequest req;
  req.tenantId = tenant;
  req.requestedBy = UserId("admin");
  req.format_ = ExportFormat.csv;
  auto r = uc.createExport(req);
  assert(r.isSuccess);
  assert(uc.getExport(tenant, ExportJobId(r.id)).totalRecords == 1);

  auto csv = uc.renderExport(tenant, ExportJobId(r.id));
  assert(csv.canFind("\"hello, world\""));
}
