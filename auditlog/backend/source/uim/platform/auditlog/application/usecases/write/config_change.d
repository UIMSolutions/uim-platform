/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.application.usecases.write.config_change;

import uim.platform.auditlog;

mixin(ShowModule!());

@safe:

/// Interactor: records a security-relevant configuration change together with its parent audit entry.
class WriteConfigChangeUseCase : IWriteConfigChangeUseCase {
  protected IAuditLogRepository auditRepo;
  protected IConfigChangeLogRepository cclRepo;
  protected IAuditConfigRepository configRepo;

  this(IAuditLogRepository auditRepo, IConfigChangeLogRepository cclRepo,
      IAuditConfigRepository configRepo = null) {
    this.auditRepo = auditRepo;
    this.cclRepo = cclRepo;
    this.configRepo = configRepo;
  }

  UsecaseResult writeChange(WriteConfigChangeLogRequest req) {
    if (req.tenantId.isEmpty)
      return UsecaseResult(false, "", "Tenant ID is required", 400);
    if (req.configType.length == 0)
      return UsecaseResult(false, "", "Config type is required", 400);

    auto cfg = configRepo is null ? AuditConfig.init : configRepo.getByTenant(req.tenantId);
    try {
      AuditPolicy.ensureAllowed(cfg, AuditCategory.configuration, AuditSeverity.info);
    } catch (AuditLogException e) {
      return UsecaseResult(false, "", e.msg, 422);
    }
    auto changes = AuditPolicy.mask(cfg, req.changes);

    auto entry = AuditLogEntry(req.tenantId, AuditLogId(generateId), req.changedBy);
    entry.userId = req.changedBy;
    entry.category = AuditCategory.configuration;
    entry.severity = AuditSeverity.info;
    entry.action = AuditAction.configChange;
    entry.outcome = AuditOutcome.success;
    entry.objectType = req.configType;
    entry.objectId = req.configObjectId;
    entry.message = "Configuration change: %s / %s by %s".format(req.configType,
      req.configObjectId, req.changedBy.value);
    entry.attributes = changes;
    entry.timestamp = entry.createdAt;
    auditRepo.save(entry);

    auto ccLog = ConfigChangeLog(req.tenantId, ConfigChangeLogId(generateId), req.changedBy);
    ccLog.auditLogId = entry.id;
    ccLog.changedBy = req.changedBy;
    ccLog.configType = req.configType;
    ccLog.configObjectId = req.configObjectId;
    ccLog.changes = changes;
    ccLog.reason = req.reason;
    ccLog.timestamp = entry.timestamp;
    cclRepo.save(ccLog);

    return UsecaseResult(true, entry.id.value, "Configuration change recorded");
  }
}
///
unittest {
  mixin(ShowTest!("WriteConfigChangeUseCase"));

  auto logs = new AuditLogRepository();
  auto ccl = new ConfigChangeLogRepository();
  auto uc = new WriteConfigChangeUseCase(logs, ccl);

  WriteConfigChangeLogRequest req;
  req.tenantId = TenantId("t1");
  req.configType = "security_policy";
  req.changedBy = UserId("admin");
  assert(uc.writeChange(req).isSuccess);
  assert(uc.writeChange(req).isSuccess);
  assert(ccl.countByTenant(req.tenantId) == 2);
}
