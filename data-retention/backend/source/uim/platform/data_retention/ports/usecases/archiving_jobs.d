/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driving port of the archiving and destruction jobs.
module uim.platform.data_retention.ports.usecases.archiving_jobs;

import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

interface IManageArchivingJobs {
  ArchivingJob create(CreateArchivingJobCommand c);
  /// Run a scheduled (or failed) job now, due or not.
  ArchivingJob run(TenantId t, ArchivingJobId id, UserId actor);
  ArchivingJob cancel(TenantId t, ArchivingJobId id, UserId actor);
  ArchivingJob get(TenantId t, ArchivingJobId id);
  ArchivingJob[] list(TenantId t);
  /// Not while running.
  void remove(TenantId t, ArchivingJobId id, UserId actor);
  /// Run every due job (background worker).
  RunSummary runDue(TenantId t, UserId actor);
}
