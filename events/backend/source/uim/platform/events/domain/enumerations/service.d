/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.domain.enumerations.service;

import uim.platform.events;

mixin(ShowModule!());

@safe:

/// Lifecycle of a messaging service instance. Only active services route messages.
enum MessagingServiceStatus : string {
  creating = "creating",
  active = "active",
  inactive = "inactive",
  updating = "updating",
  deleting = "deleting",
  failed = "failed"
}

/// Service plan. The plan defines the default quotas (see QuotaPolicy).
enum MessagingServicePlan : string {
  dev = "dev",
  standard = "standard",
  premium = "premium"
}
