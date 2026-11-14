/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.ports.usecases.dev_spaces;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

/// Create, start/stop and delete dev spaces. `create` and `start` request a
/// start (status starting / resuming); `remove` requests deletion (status
/// deleting). The reconciler completes them; deletion cascades to projects,
/// bindings and configurations.
interface IManageDevSpacesUseCase : IManageResource!(DevSpace, DevSpaceId,
    CreateDevSpaceRequest, UpdateDevSpaceRequest) {
  UsecaseResult start(TenantId tenantId, DevSpaceId id, UserId actor);
  UsecaseResult stop(TenantId tenantId, DevSpaceId id, UserId actor);
  /// Record developer activity (postpones hibernation).
  UsecaseResult touch(TenantId tenantId, DevSpaceId id, UserId actor);
  UsecaseResult addExtension(TenantId tenantId, DevSpaceId id, string extension, UserId actor);
  UsecaseResult removeExtension(TenantId tenantId, DevSpaceId id, string extension, UserId actor);
}
