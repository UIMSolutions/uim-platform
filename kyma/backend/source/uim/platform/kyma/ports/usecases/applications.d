/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.ports.usecases.applications;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

/// Application Connectivity: register, pair and bind external systems.
interface IManageApplicationsUseCase : IManageResource!(KymaApplication, ApplicationId,
    RegisterApplicationRequest, UpdateApplicationRequest) {
  UsecaseResult connect(TenantId tenantId, ApplicationId id, UserId actor);
  UsecaseResult disconnect(TenantId tenantId, ApplicationId id, UserId actor);
  UsecaseResult bindNamespace(TenantId tenantId, ApplicationId id, string namespaceName, UserId actor);
  UsecaseResult unbindNamespace(TenantId tenantId, ApplicationId id, string namespaceName, UserId actor);
}
