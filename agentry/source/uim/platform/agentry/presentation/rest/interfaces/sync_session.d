/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.presentation.rest.interfaces.sync_session;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

interface ISyncSessionApi {
    @headerParam("tenantId", "X-Tenant-Id")
    SyncSession[] listSyncSessions(string tenantId);

    @headerParam("tenantId", "X-Tenant-Id")
    SyncSession getSyncSession(string tenantId, string sessionId);

    @headerParam("tenantId", "X-Tenant-Id")
    void createSyncSession(string tenantId, SyncSession session);

    @headerParam("tenantId", "X-Tenant-Id")
    void updateSyncSession(string tenantId, SyncSession session);

    @headerParam("tenantId", "X-Tenant-Id")
    void deleteSyncSession(string tenantId, string sessionId);
}
