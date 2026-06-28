/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.customer_identity.application.usecases.manage.audit_logs;

import uim.platform.customer_identity;

// mixin(ShowModule!());

@safe:

class ManageAuditLogsUseCase {
    private AuditLogRepository repo;

    this(AuditLogRepository repo) {
        this.repo = repo;
    }

    AuditLog getAuditLog(TenantId tenantId, AuditLogId id) {
        return repo.findById(tenantId, id);
    }

    AuditLog[] listAuditLogs(TenantId tenantId) {
        return repo.find(tenantId);
    }

    AuditLog[] listByActor(TenantId tenantId, string actorId) {
        return repo.findByActor(tenantId, actorId);
    }

    CommandResult recordAuditEvent(AuditLogDTO dto) {
        
        AuditLog al;
        al.initEntity(dto.tenantId, dto.createdBy);
        al.actorId = dto.actorId;
        al.resourceId = dto.resourceId;
        al.ipAddress = dto.ipAddress;
        al.userAgent = dto.userAgent;
        al.details = dto.details;
        al.success = dto.success;
        al.timestamp = MonoTime.currTime.ticks;

        
        try { al.action = dto.action.to!AuditAction; }
        catch (Exception) { return CommandResult(false, "", "Invalid audit action"); }
        try { al.resourceType = dto.resourceType.to!ResourceType; }
        catch (Exception) { return CommandResult(false, "", "Invalid resource type"); }

        if (!IdentityValidator.isValidAuditLog(al))
            return CommandResult(false, "", "Invalid audit log data");

        repo.save(al);
        return CommandResult(true, al.id.value, "");
    }

    CommandResult deleteAuditLog(TenantId tenantId, AuditLogId id) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Audit log not found");

        repo.remove(existing);
        return CommandResult(true, existing.id.value, "");
    }
}
