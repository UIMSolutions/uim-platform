/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Time source (system clock in production, a manual clock in tests —
/// retention is all about time, so every interactor asks this port).
module uim.platform.data_retention.ports.gateways.clock;

import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

interface IClock {
  /// Current std time (hnsecs, UTC).
  long now();
}
