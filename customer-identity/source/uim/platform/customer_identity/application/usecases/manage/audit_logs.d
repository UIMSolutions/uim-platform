/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.customer_identity.application.usecases.manage.audit_logs;

import uim.platform.customer_identity;

mixin(ShowModule!());

@safe:

class ManageAuditLogsUseCase {
    private IAuditLogRepository repo;

    this(IAuditLogRepository repo) {
        this.repo = repo;
    }

    AuditLog getAuditLog(TenantId tenantId, AuditLogId id) {
        return repo.findById(tenantId, id);
    }

    AuditLog[] listAuditLogs(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    AuditLog[] listAuditLogs(TenantId tenantId, string actorId) {
        return repo.findByActor(tenantId, actorId);
    }

    UsecaseResult recordAuditEvent(AuditLogDTO dto) {
        
        auto al = AuditLog(dto.tenantId); //, dto.createdBy);
        al.actorId = dto.actorId;
        al.resourceId = dto.resourceId;
        al.ipAddress = dto.ipAddress;
        al.userAgent = dto.userAgent;
        al.details = dto.details;
        al.success = dto.success;
        al.timestamp = MonoTime.currTime.ticks;

        
        try { al.action = dto.action.to!AuditAction; }
        catch (Exception) { return UsecaseResult(false, "", "Invalid audit action"); }
        try { al.resourceType = dto.resourceType.to!ResourceType; }
        catch (Exception) { return UsecaseResult(false, "", "Invalid resource type"); }

        if (!IdentityValidator.isValidAuditLog(al))
            return UsecaseResult(false, "", "Invalid audit log data");

        repo.save(al);
        return UsecaseResult(true, al.id.value, "");
    }

    UsecaseResult deleteAuditLog(TenantId tenantId, AuditLogId id) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return UsecaseResult(false, "", "Audit log not found");

        repo.remove(existing);
        return UsecaseResult(true, existing.id.value, "");
    }
}
