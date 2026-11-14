/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.ports.usecases.environment_instances;

import uim.platform.management;

mixin(ShowModule!());

@safe:

/// Driving port: manage the environment instance lifecycle (CF, Kyma, ABAP).
interface IManageEnvironmentsUseCase {
  UsecaseResult createEnvironment(CreateEnvironmentRequest req);
  UsecaseResult updateEnvironment(UpdateEnvironmentRequest req);
  UsecaseResult deprovisionEnvironment(TenantId tenantId, EnvironmentId id);
  Environment getEnvironment(TenantId tenantId, EnvironmentId id);
  Environment[] listEnvironments(TenantId tenantId);
  Environment[] listEnvironments(TenantId tenantId, SubaccountId subId);
  Environment[] listEnvironments(TenantId tenantId, SubaccountId subId, string envType);
}
