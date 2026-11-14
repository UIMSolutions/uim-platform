/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.ports.usecases.run_configurations;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

/// Run configurations of a project. `start` needs a running dev space and free ports.
interface IManageRunConfigurationsUseCase : IManageResource!(RunConfiguration, RunConfigurationId,
    CreateRunConfigurationRequest, UpdateRunConfigurationRequest) {
  UsecaseResult start(TenantId tenantId, RunConfigurationId id, UserId actor);
  UsecaseResult stop(TenantId tenantId, RunConfigurationId id, UserId actor);
}
