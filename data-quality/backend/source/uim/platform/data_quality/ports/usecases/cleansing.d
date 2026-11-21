/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driving ports of cleansing: batch jobs and address cleansing.
module uim.platform.data_quality.ports.usecases.cleansing;

import uim.platform.data_quality;

mixin(ShowModule!());

@safe:

interface IManageCleansingJobs {
  /// Creates a pending job (run by the worker, by runJob, or at once if
  /// the worker is disabled).
  CleansingJob createCleansingJob(CreateCleansingJobRequest r);
  CleansingJob getCleansingJob(TenantId t, DatasetId ds, CleansingJobId id);
  CleansingJob[] listCleansingJobs(TenantId t, DatasetId ds);
  CleansingJob runCleansingJob(TenantId t, DatasetId ds, CleansingJobId id, UserId actor);
  CleansingJob cancelCleansingJob(TenantId t, DatasetId ds, CleansingJobId id, UserId actor);
  /// Refused while the job is running.
  void deleteCleansingJob(TenantId t, DatasetId ds, CleansingJobId id);
  /// Run every pending job of the tenant (background worker).
  JobRunSummary runPendingJobs(TenantId t);
}

interface ICleanseAddresses {
  /// Cleanse an address; stored unless r.persist is false.
  PostalAddress cleanseAddress(CleanseAddressRequest r);
  PostalAddress getAddress(TenantId t, AddressId id);
  PostalAddress[] listAddresses(TenantId t);
  void deleteAddress(TenantId t, AddressId id);
}
