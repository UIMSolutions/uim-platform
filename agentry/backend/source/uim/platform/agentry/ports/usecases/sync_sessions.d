/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.ports.usecases.sync_sessions;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

/// Driving port: track data synchronization between devices and backends.
interface IManageSyncSessionsUseCase {
  SyncSession[] listSyncSessions(TenantId tenantId);
  SyncSession[] listByDevice(TenantId tenantId, DeviceId deviceId);
  SyncSession[] listByStatus(TenantId tenantId, SyncStatus status);
  SyncSession getSyncSession(TenantId tenantId, SyncSessionId id);

  /// Register a pending session. The device must not be suspended or removed.
  UsecaseResult createSyncSession(SyncSessionDTO dto);
  UsecaseResult updateSyncSession(SyncSessionDTO dto);
  UsecaseResult startSyncSession(TenantId tenantId, SyncSessionId id);
  /// Completes the session and updates the device (lastSeenAt, installed version).
  UsecaseResult completeSyncSession(TenantId tenantId, SyncSessionId id, SyncMetricsDTO metrics);
  UsecaseResult failSyncSession(TenantId tenantId, SyncSessionId id, string errorMessage);
  UsecaseResult cancelSyncSession(TenantId tenantId, SyncSessionId id);
  /// Fail sessions that are in progress for longer than timeoutMinutes. Returns the count in result.data["expired"].
  UsecaseResult expireStaleSessions(TenantId tenantId, int timeoutMinutes);
  UsecaseResult deleteSyncSession(TenantId tenantId, SyncSessionId id);
}
