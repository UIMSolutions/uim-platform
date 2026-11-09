/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.application.usecases.write.audit_log;

import uim.platform.auditlog;

mixin(ShowModule!());

@safe:

/// Interactor: records a generic audit log entry after checking the tenant's
/// audit configuration (see domain service AuditPolicy).
class WriteAuditLogUseCase : IWriteAuditLogUseCase {
  protected IAuditLogRepository logRepo;
  protected IAuditConfigRepository configRepo;
  protected IAuditEventPublisher publisher;

  this(IAuditLogRepository logRepo, IAuditConfigRepository configRepo,
      IAuditEventPublisher publisher = null) {
    this.logRepo = logRepo;
    this.configRepo = configRepo;
    this.publisher = publisher;
  }

  UsecaseResult writeAuditLog(WriteAuditLogRequest req) {
    if (req.tenantId.isEmpty)
      return UsecaseResult(false, "", "Tenant ID is required", 400);
    if (req.message.length == 0)
      return UsecaseResult(false, "", "Message is required", 400);

    auto cfg = configRepo.getByTenant(req.tenantId);
    try {
      AuditPolicy.ensureAllowed(cfg, req.category, req.severity);
    } catch (AuditLogException e) {
      return UsecaseResult(false, "", e.msg, 422);
    }

    auto entry = AuditLogEntry(req.tenantId);
    entry.userId = req.userId;
    entry.userName = req.userName;
    entry.serviceId = req.serviceId;
    entry.serviceName = req.serviceName;
    entry.category = req.category;
    entry.severity = req.severity;
    entry.action = req.action;
    entry.outcome = req.outcome;
    entry.objectType = req.objectType;
    entry.objectId = req.objectId;
    entry.message = req.message;
    entry.attributes = AuditPolicy.mask(cfg, req.attributes);
    entry.ipAddress = req.ipAddress;
    entry.userAgent = req.userAgent;
    entry.correlationId = req.correlationId;
    entry.originApp = req.originApp;
    entry.timestamp = entry.createdAt;

    logRepo.save(entry);
    if (publisher !is null)
      publisher.publish(AuditTopics.entryWritten, entry.toJson);

    return UsecaseResult(true, entry.id.value, "Audit log entry created");
  }
}
///
unittest {
  mixin(ShowTest!("WriteAuditLogUseCase"));

  auto logs = new AuditLogRepository();
  auto configs = new AuditConfigRepository();
  auto uc = new WriteAuditLogUseCase(logs, configs);
  auto tenant = TenantId("t1");

  WriteAuditLogRequest req;
  req.tenantId = tenant;
  req.category = AuditCategory.dataModification;
  req.message = "changed";
  auto r = uc.writeAuditLog(req);
  assert(r.isSuccess, r.message);
  assert(logs.countByTenant(tenant) == 1);

  // Category switched off => rejected
  auto cfg = AuditConfig.createDefault(tenant);
  cfg.logDataModification = false;
  configs.save(cfg);
  assert(!uc.writeAuditLog(req).isSuccess);
  assert(logs.countByTenant(tenant) == 1);

  req.message = "";
  assert(uc.writeAuditLog(req).hasError);
}
