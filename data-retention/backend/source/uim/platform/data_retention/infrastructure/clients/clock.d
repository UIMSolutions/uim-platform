/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Adapters of the IClock gateway.
module uim.platform.data_retention.infrastructure.clients.clock;

import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

/// System clock (UTC).
class SystemClock : IClock {
  long now() {
    return nowStdTime();
  }
}

/// Settable clock for tests and simulations.
class ManualClock : IClock {
  long current;

  this(long start) {
    current = start;
  }

  long now() {
    return current;
  }

  void advance(long seconds) {
    current = plusSeconds(current, seconds);
  }
}

///
unittest {
  auto c = new ManualClock(100);
  c.advance(1);
  assert(c.now == 100 + hnsecsPerSecondL);
  assert(new SystemClock().now > 0);
}
