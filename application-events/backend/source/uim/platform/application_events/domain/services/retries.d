/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Retry policy of at-least-once delivery: exponential back-off
/// (base · 2^(attempt-1), capped) after each failed attempt; after the
/// last allowed attempt the message becomes a dead letter. At-most-once
/// channels make one attempt and drop failed messages.
module uim.platform.application_events.domain.services.retries;

import uim.platform.application_events;

mixin(ShowModule!());

@safe:

/// Seconds to wait after the given failed attempt (1 = first attempt).
long backoffSeconds(int attempt, long baseSeconds, long capSeconds) pure {
  if (attempt < 1)
    attempt = 1;
  long delay = baseSeconds < 1 ? 1 : baseSeconds;
  foreach (_; 1 .. attempt) {
    delay *= 2;
    if (delay >= capSeconds)
      return capSeconds;
  }
  return delay < capSeconds ? delay : capSeconds;
}

/// What happens to a message after a failed attempt.
enum FailureOutcome {
  retry,
  deadLetter,
  drop
}

FailureOutcome afterFailure(DeliveryMode mode, int attempts, int maxAttempts) pure {
  if (mode == DeliveryMode.atMostOnce)
    return FailureOutcome.drop;
  return attempts >= maxAttempts ? FailureOutcome.deadLetter : FailureOutcome.retry;
}

///
unittest {
  assert(backoffSeconds(1, 30, 3600) == 30 && backoffSeconds(2, 30, 3600) == 60 && backoffSeconds(4, 30, 3600) == 240);
  assert(backoffSeconds(20, 30, 3600) == 3600 && backoffSeconds(0, 0, 10) == 1);
  assert(afterFailure(DeliveryMode.atLeastOnce, 1, 3) == FailureOutcome.retry);
  assert(afterFailure(DeliveryMode.atLeastOnce, 3, 3) == FailureOutcome.deadLetter);
  assert(afterFailure(DeliveryMode.atMostOnce, 1, 3) == FailureOutcome.drop);
}
