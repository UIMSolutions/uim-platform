/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.infrastructure.persistence.memory.sync_sessions;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

class MemorySyncSessionRepository
    : TenantRepository!(SyncSession, SyncSessionId), SyncSessionRepository {

    SyncSession[] findByDevice(TenantId tenantId, DeviceId deviceId) {
        return findByTenant(tenantId).filter!(s => s.deviceId == deviceId).array;
    }

    SyncSession[] findByStatus(TenantId tenantId, SyncStatus status) {
        return findByTenant(tenantId).filter!(s => s.status == status).array;
    }

    SyncSession[] findByMobileApplication(TenantId tenantId, MobileApplicationId appId) {
        return findByTenant(tenantId).filter!(s => s.mobileApplicationId == appId).array;
    }

    size_t countByStatus(TenantId tenantId, SyncStatus status) {
        return findByStatus(tenantId, status).length;
    }
}
