/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_provisioning.ports.usecases.jobs;

import uim.platform.identity_provisioning;

mixin(ShowModule!());

@safe:

/// Maintain and run provisioning jobs.
interface IManageProvisioningJobsUseCase : IManageResource!(ProvisioningJob, ProvisioningJobId,
    CreateJobRequest, UpdateJobRequest) {
  /// Run now: read the source, transform, write the target, log every operation.
  UsecaseResult run(TenantId tenantId, ProvisioningJobId id, UserId actor);
  /// Switch the job off (no scheduled or manual runs).
  UsecaseResult cancel(TenantId tenantId, ProvisioningJobId id, UserId actor);
  /// cancelled → scheduled.
  UsecaseResult resume(TenantId tenantId, ProvisioningJobId id, UserId actor);
  /// Forget the delta state: the next run creates every entity again.
  UsecaseResult reset(TenantId tenantId, ProvisioningJobId id, UserId actor);
  /// Run every due scheduled job (now = 0: current time; limit = 0: all).
  JobRunReport runDue(TenantId tenantId, long now = 0, int limit = 0);
  ProvisioningJob findByName(TenantId tenantId, string name);
}
