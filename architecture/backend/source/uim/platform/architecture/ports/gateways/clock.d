/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Time source (injectable for tests).
module uim.platform.architecture.ports.gateways.clock;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

interface IClock {
  /// Current time as std time (hnsecs, UTC).
  long now();
}
