/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.domain.repositories.sync_sessions;

import uim.platform.agentry;

// mixin(ShowModule!());

@safe:

interface SyncSessionRepository : ITenantRepository!(SyncSession, SyncSessionId) {
    SyncSession[] findByDevice(TenantId tenantId, DeviceId deviceId);
    SyncSession[] findByStatus(TenantId tenantId, SyncStatus status);
    SyncSession[] findByMobileApplication(TenantId tenantId, MobileApplicationId appId);
    size_t countByStatus(TenantId tenantId, SyncStatus status);
}
