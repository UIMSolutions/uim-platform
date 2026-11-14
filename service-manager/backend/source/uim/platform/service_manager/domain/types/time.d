/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Time values. Entities store timestamps as std time (hnsecs since 0001-01-01 UTC).
module uim.platform.service_manager.domain.types.time;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

/// Current time in std time.
long nowStdTime() @trusted {
  return Clock.currStdTime();
}
