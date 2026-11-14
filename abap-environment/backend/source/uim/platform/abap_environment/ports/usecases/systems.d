/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.ports.usecases.systems;

import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:

/// Provision, suspend/resume, upgrade and delete ABAP systems.
/// `remove` requests deprovisioning (status deleting); the reconciler finishes it
/// and deletes all objects of the system.
interface IManageSystemsUseCase : IManageResource!(SystemInstance, SystemInstanceId,
    CreateSystemRequest, UpdateSystemRequest) {
  UsecaseResult suspend(TenantId tenantId, SystemInstanceId id, UserId actor);
  UsecaseResult resume(TenantId tenantId, SystemInstanceId id, UserId actor);
  /// Start a software update (active → updating → active).
  UsecaseResult upgrade(TenantId tenantId, SystemInstanceId id, string softwareVersion, UserId actor);
}
