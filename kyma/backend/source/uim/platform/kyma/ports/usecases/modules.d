/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.ports.usecases.modules;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

/// Enable / disable Kyma modules with dependency checks.
/// `create` enables a module; `remove` deletes a disabled module.
interface IManageModulesUseCase : IManageResource!(KymaModule, KymaModuleId,
    EnableModuleRequest, UpdateModuleRequest) {
  UsecaseResult disable(TenantId tenantId, KymaModuleId id, UserId actor);
  UsecaseResult enable(TenantId tenantId, KymaModuleId id, UserId actor);
}
