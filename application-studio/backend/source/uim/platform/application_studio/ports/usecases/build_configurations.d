/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.ports.usecases.build_configurations;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

/// Build configurations of a project. `build` and `deploy` queue a run the reconciler executes.
interface IManageBuildConfigurationsUseCase : IManageResource!(BuildConfiguration, BuildConfigurationId,
    CreateBuildConfigurationRequest, UpdateBuildConfigurationRequest) {
  UsecaseResult build(TenantId tenantId, BuildConfigurationId id, UserId actor);
  UsecaseResult deploy(TenantId tenantId, BuildConfigurationId id, UserId actor);
  UsecaseResult cancel(TenantId tenantId, BuildConfigurationId id, UserId actor);
}
