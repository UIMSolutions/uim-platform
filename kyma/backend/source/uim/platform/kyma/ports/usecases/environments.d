/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.ports.usecases.environments;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

/// Provision, resize, stop/start and delete Kyma runtimes.
interface IManageEnvironmentsUseCase : IManageResource!(KymaEnvironment, KymaEnvironmentId,
    CreateEnvironmentRequest, UpdateEnvironmentRequest) {
  /// Hibernate a running runtime (running → stopping → stopped).
  UsecaseResult stop(TenantId tenantId, KymaEnvironmentId id, UserId actor);
  /// Wake up a stopped runtime (stopped → updating → running).
  UsecaseResult start(TenantId tenantId, KymaEnvironmentId id, UserId actor);
}
