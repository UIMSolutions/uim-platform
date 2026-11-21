/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Clock adapters.
module uim.platform.architecture.infrastructure.clients.clock;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

class SystemClock : IClock {
  long now() {
    return nowStdTime();
  }
}

/// Settable clock for tests.
class FixedClock : IClock {
  long time;

  this(long time) {
    this.time = time;
  }

  long now() {
    return time;
  }
}
