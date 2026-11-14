/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.ports.usecases.transport_requests;

import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:

/// Transport workflow: tasks, release (tasks first), import into the target system.
interface IManageTransportRequestsUseCase : IManageResource!(TransportRequest, TransportRequestId,
    CreateTransportRequestRequest, UpdateTransportRequestRequest) {
  UsecaseResult addTask(TenantId tenantId, TransportRequestId id, string owner, string description,
      string[] objects, UserId actor);
  UsecaseResult releaseTask(TenantId tenantId, TransportRequestId id, string taskId, UserId actor);
  UsecaseResult release(TenantId tenantId, TransportRequestId id, UserId actor);
  /// Queue the import into the target system (released → importing).
  UsecaseResult import_(TenantId tenantId, TransportRequestId id, UserId actor);
}
