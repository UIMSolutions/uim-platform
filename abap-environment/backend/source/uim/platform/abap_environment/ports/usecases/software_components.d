/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.ports.usecases.software_components;

import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:

/// gCTS software components: register, clone, pull, switch branch.
interface IManageSoftwareComponentsUseCase : IManageResource!(SoftwareComponent, SoftwareComponentId,
    CreateSoftwareComponentRequest, UpdateSoftwareComponentRequest) {
  UsecaseResult clone(TenantId tenantId, SoftwareComponentId id, UserId actor);
  UsecaseResult pull(TenantId tenantId, SoftwareComponentId id, UserId actor);
  UsecaseResult checkout(TenantId tenantId, SoftwareComponentId id, string branch, UserId actor);
}
