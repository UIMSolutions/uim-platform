/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.application.usecases.write.data_access_log;

import uim.platform.auditlog;

mixin(ShowModule!());

@safe:

/// Interactor: records a GDPR-relevant read access together with its parent audit entry.
class WriteDataAccessLogUseCase : IWriteDataAccessLogUseCase {
  protected IAuditLogRepository auditRepo;
  protected IDataAccessLogRepository dalRepo;
  protected IAuditConfigRepository configRepo;

  this(IAuditLogRepository auditRepo, IDataAccessLogRepository dalRepo,
      IAuditConfigRepository configRepo = null) {
    this.auditRepo = auditRepo;
    this.dalRepo = dalRepo;
    this.configRepo = configRepo;
  }

  UsecaseResult writeLog(WriteDataAccessLogRequest req) {
    if (req.tenantId.isEmpty)
      return UsecaseResult(false, "", "Tenant ID is required", 400);
    if (req.dataSubject.length == 0)
      return UsecaseResult(false, "", "Data subject is required", 400);

    if (configRepo !is null) {
      try {
        AuditPolicy.ensureAllowed(configRepo.getByTenant(req.tenantId), AuditCategory.dataAccess, AuditSeverity.info);
      } catch (AuditLogException e) {
        return UsecaseResult(false, "", e.msg, 422);
      }
    }

    auto entry = AuditLogEntry(req.tenantId);
    entry.userId = req.accessedBy;
    entry.category = AuditCategory.dataAccess;
    entry.severity = AuditSeverity.info;
    entry.action = AuditAction.dataAccess;
    entry.outcome = AuditOutcome.success;
    entry.objectType = req.dataObjectType;
    entry.objectId = req.dataObjectId;
    entry.message = "Data access: %s / %s by %s purpose=%s".format(req.dataObjectType,
      req.dataObjectId, req.accessedBy.value, req.purpose);
    entry.timestamp = entry.createdAt;
    auditRepo.save(entry);

    auto daLog = DataAccessLog(req.tenantId);
    daLog.auditLogId = entry.id;
    daLog.accessedBy = req.accessedBy;
    daLog.dataSubject = req.dataSubject;
    daLog.dataObjectType = req.dataObjectType;
    daLog.dataObjectId = req.dataObjectId;
    daLog.accessedFields = req.accessedFields;
    daLog.purpose = req.purpose;
    daLog.channel = req.channel;
    daLog.timestamp = entry.timestamp;
    dalRepo.save(daLog);

    return UsecaseResult(true, entry.id.value, "Data access recorded");
  }
}
///
unittest {
  mixin(ShowTest!("WriteDataAccessLogUseCase"));

  auto logs = new AuditLogRepository();
  auto dal = new DataAccessLogRepository();
  auto uc = new WriteDataAccessLogUseCase(logs, dal);

  WriteDataAccessLogRequest req;
  req.tenantId = TenantId("t1");
  assert(uc.writeLog(req).hasError); // data subject missing
  req.dataSubject = "employee-4711";
  assert(uc.writeLog(req).isSuccess);
  assert(uc.writeLog(req).isSuccess);
  assert(dal.countByTenant(req.tenantId) == 2);
}
