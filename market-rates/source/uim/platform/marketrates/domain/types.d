/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.marketrates.domain.types;

import uim.platform.marketrates;

mixin(ShowModule!());

@safe:

// ---------------------------------------------------------------------------
// Domain ID value objects
// ---------------------------------------------------------------------------

struct MarketRateId {
  mixin(IdTemplate);
}

struct ProviderId {
  mixin(IdTemplate);
}

struct AuditLogId {
  mixin(IdTemplate);
}
