/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Results of application operations.
module uim.platform.architecture.application.dtos.results;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

struct SeedResult {
  size_t blocks;
  size_t relationships;
}
