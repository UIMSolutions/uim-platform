/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.domain.ports.usecases.environments;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:
/// Application service for Kyma environment lifecycle management.
interface IManageEnvironmentsUseCase {

  UsecaseResult createEnvironment(CreateEnvironmentRequest req) {

  UsecaseResult updateEnvironment(TenantId tenantId, KymaEnvironmentId id, UpdateEnvironmentRequest req);

  bool hasEnvironment(TenantId tenantId, KymaEnvironmentId id);

  KymaEnvironment getEnvironment(TenantId tenantId, KymaEnvironmentId id);

  KymaEnvironment[] listEnvironments(TenantId tenantId);

  KymaEnvironment[] listEnvironments(TenantId tenantId, SubaccountId subId);

  UsecaseResult deleteEnvironment(TenantId tenantId, KymaEnvironmentId id),

}


