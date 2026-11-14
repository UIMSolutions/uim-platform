/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.translation.ports.usecases.jobs;

import uim.platform.translation;

mixin(ShowModule!());

@safe:

/// Submit and run asynchronous translation jobs.
interface IManageJobsUseCase : IManageResource!(TranslationJob, TranslationJobId,
    SubmitJobRequest, UpdateJobRequest) {
  /// Run one pending job now.
  UsecaseResult process(TenantId tenantId, TranslationJobId id, UserId actor);
  /// Run all pending jobs of the tenant (oldest first, at most `limit`, 0 = all).
  JobRunReport processPending(TenantId tenantId, int limit = 0);
  UsecaseResult cancel(TenantId tenantId, TranslationJobId id, UserId actor);
  /// failed/cancelled → pending.
  UsecaseResult retry(TenantId tenantId, TranslationJobId id, UserId actor);
}
