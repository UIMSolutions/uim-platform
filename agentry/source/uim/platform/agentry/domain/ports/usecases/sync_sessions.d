/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.domain.tests.usecases.manage.sync_sessions;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

interface IManageSyncSessionsUseCase {

    SyncSession getSyncSession(TenantId tenantId, SyncSessionId id);
    SyncSession[] listSyncSessions(TenantId tenantId);
    SyncSession[] listByDevice(TenantId tenantId, DeviceId deviceId);
    SyncSession[] listByStatus(TenantId tenantId, SyncStatus status);

    CommandResult createSyncSession(SyncSessionDTO dto);
    CommandResult updateSyncSession(SyncSessionDTO dto);
    CommandResult deleteSyncSession(TenantId tenantId, SyncSessionId id);

}
