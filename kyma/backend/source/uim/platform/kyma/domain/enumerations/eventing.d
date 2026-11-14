/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.domain.enumerations.eventing;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

/// How event types of a subscription are matched.
enum EventTypeEncoding {
  exact,
  prefix,
}

/// Status of an eventing subscription.
enum SubscriptionStatus {
  pending,
  active,
  paused,
  error,
}

///
unittest {
  assert(parseEnum!SubscriptionStatus("paused", SubscriptionStatus.error) == SubscriptionStatus.paused);
}
