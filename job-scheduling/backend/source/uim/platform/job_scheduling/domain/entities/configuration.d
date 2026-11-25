/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The scheduler settings of a tenant (one per tenant; defaults apply
/// until it is changed).
module uim.platform.job_scheduling.domain.entities.configuration;

import uim.platform.job_scheduling;

mixin(ShowModule!());

@safe:

/// Id of the (single) configuration of a tenant.
enum string tenantConfigurationId = "settings";

struct SchedulerConfiguration {
  mixin TenantEntity!ConfigurationId;

  bool schedulerEnabled = true; /// false pauses all schedules of the tenant (manual runs still work)
  int defaultRetries = 2; /// retries after a failed call (jobs may override)
  int retryDelaySeconds = 60; /// wait before a retry (doubles with every attempt)
  int requestTimeoutSeconds = 30; /// synchronous calls
  int asyncTimeoutSeconds = 3600; /// how long asynchronous runs may take until their callback
  int runLogRetentionDays = 30; /// final run logs older than this are purged (0 = keep)

  /// Retry delay of an attempt: retryDelaySeconds × 2^(attempt-1), at most one day.
  long retryDelayFor(int attempt) const pure {
    long d = retryDelaySeconds;
    foreach (_; 1 .. attempt)
      if (d < 86_400)
        d *= 2;
    return d < 86_400 ? d : 86_400;
  }

  void validate() const {
    requireRange(defaultRetries, 0, maxJobRetries, "Default retries");
    requireRange(retryDelaySeconds, 1, 86_400, "Retry delay");
    requireRange(requestTimeoutSeconds, 1, 600, "Request timeout");
    requireRange(asyncTimeoutSeconds, 10, maxTimeoutSeconds, "Asynchronous timeout");
    requireRange(runLogRetentionDays, 0, 3650, "Run log retention");
  }
}

///
unittest {
  SchedulerConfiguration c;
  c.validate();
  assert(c.retryDelayFor(1) == 60 && c.retryDelayFor(3) == 240);
  c.retryDelaySeconds = 50_000;
  assert(c.retryDelayFor(5) == 86_400);
  c.requestTimeoutSeconds = 0;
  assert(failsWith(JsErrorKind.invalid, () { c.validate(); }));
}
