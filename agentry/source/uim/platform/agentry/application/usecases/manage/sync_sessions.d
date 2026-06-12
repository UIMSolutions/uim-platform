/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.application.usecases.manage.sync_sessions;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

class ManageSyncSessionsUseCase {
    private SyncSessionRepository repo;

    this(SyncSessionRepository repo) {
        this.repo = repo;
    }

    SyncSession getSyncSession(TenantId tenantId, SyncSessionId id) {
        return repo.findById(tenantId, id);
    }

    SyncSession[] listSyncSessions(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    SyncSession[] listByDevice(TenantId tenantId, DeviceId deviceId) {
        return repo.findByDevice(tenantId, deviceId);
    }

    SyncSession[] listByStatus(TenantId tenantId, SyncStatus status) {
        return repo.findByStatus(tenantId, status);
    }

    CommandResult createSyncSession(SyncSessionDTO dto) {
        SyncSession session;
        session.initEntity(dto.tenantId, dto.createdBy);
        session.id = dto.sessionId;
        session.deviceId = dto.deviceId;
        session.applicationId = dto.applicationId;
        session.connectionId = dto.connectionId;
        session.triggeredBy = dto.triggeredBy;
        session.clientAppVersion = dto.clientAppVersion;

        if (!AgentryValidator.isValidSyncSession(session))
            return CommandResult(false, "", "Invalid sync session data");

        repo.save(session);
        return CommandResult(true, session.id.value, "");
    }

    CommandResult updateSyncSession(SyncSessionDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.sessionId);
        if (existing.isNull)
            return CommandResult(false, "", "Sync session not found");

        if (dto.status.length > 0) {
            
            existing.status = dto.status.to!SyncStatus;
        }
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteSyncSession(TenantId tenantId, SyncSessionId id) {
        auto entity = repo.findById(tenantId, id);
        if (entity.isNull)
            return CommandResult(false, "", "Sync session not found");

        repo.remove(entity);
        return CommandResult(true, entity.id.value, "");
    }
}
