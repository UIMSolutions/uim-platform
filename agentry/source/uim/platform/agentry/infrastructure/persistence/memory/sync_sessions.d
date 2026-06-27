/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.infrastructure.persistence.memory.sync_sessions;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

class MemorySyncSessionRepository : TenantRepository!(SyncSession, SyncSessionId), SyncSessionRepository {
    mixin TenantRepositoryTemplate!(MemorySyncSessionRepository, SyncSession, SyncSessionId);

    size_t countByDevice(TenantId tenantId, DeviceId deviceId) {
        return findByDevice(tenantId, deviceId).length;
    }

    SyncSession[] filterByDevice(SyncSession[] sessions, DeviceId deviceId) {
        return sessions.filter!(s => s.deviceId == deviceId).array;
    }

    SyncSession[] findByDevice(TenantId tenantId, DeviceId deviceId) {
        return filterByDevice(find(tenantId), deviceId);
    }
    void removeByDevice(TenantId tenantId, DeviceId deviceId) {
        findByDevice(tenantId, deviceId).each!(e => remove(e));
    }

    size_t countByMobileApplication(TenantId tenantId, MobileApplicationId appId) {
        return findByMobileApplication(tenantId, appId).length;
    }
    SyncSession[] filterByMobileApplication(SyncSession[] sessions, MobileApplicationId appId) {
        return sessions.filter!(s => s.applicationId == appId).array;
    }
    SyncSession[] findByMobileApplication(TenantId tenantId, MobileApplicationId appId) {
        return filterByMobileApplication(find(tenantId), appId);
    }
    void removeByMobileApplication(TenantId tenantId, MobileApplicationId appId) {
        findByMobileApplication(tenantId, appId).each!(e => remove(e));
    }

    size_t countByStatus(TenantId tenantId, SyncStatus status) {
        return findByStatus(tenantId, status).length;
    }
    SyncSession[] filterByStatus(SyncSession[] sessions, SyncStatus status) {
        return sessions.filter!(s => s.status == status).array;
    }
    SyncSession[] findByStatus(TenantId tenantId, SyncStatus status) {
        return filterByStatus(find(tenantId), status);
    }
    void removeByStatus(TenantId tenantId, SyncStatus status) {
        findByStatus(tenantId, status).each!(e => remove(e));
    }

}
