/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.ports.usecases.backend_connections;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

/// Driving port: maintain and test SAP backend connections.
interface IManageBackendConnectionsUseCase {
  BackendConnection[] listBackendConnections(TenantId tenantId);
  BackendConnection[] listByBackendType(TenantId tenantId, BackendType backendType);
  BackendConnection[] listByStatus(TenantId tenantId, ConnectionStatus status);
  BackendConnection getBackendConnection(TenantId tenantId, BackendConnectionId id);

  UsecaseResult createBackendConnection(BackendConnectionDTO dto);
  UsecaseResult updateBackendConnection(BackendConnectionDTO dto);
  /// Probe the backend URL and record the result (status, lastTestedAt/By).
  UsecaseResult testBackendConnection(TenantId tenantId, BackendConnectionId id, UserId by);
  UsecaseResult deleteBackendConnection(TenantId tenantId, BackendConnectionId id);
}
