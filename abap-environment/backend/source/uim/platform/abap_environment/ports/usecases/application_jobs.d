/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.ports.usecases.application_jobs;

import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:

/// Application jobs: schedule, run now, cancel, reactivate.
interface IManageApplicationJobsUseCase : IManageResource!(ApplicationJob, ApplicationJobId,
    CreateApplicationJobRequest, UpdateApplicationJobRequest) {
  UsecaseResult run(TenantId tenantId, ApplicationJobId id, UserId actor);
  UsecaseResult cancel(TenantId tenantId, ApplicationJobId id, UserId actor);
  UsecaseResult reactivate(TenantId tenantId, ApplicationJobId id, UserId actor);
}
