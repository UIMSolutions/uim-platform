/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.market_refinitiv.domain.types;

import uim.platform.market_refinitiv;

mixin(ShowModule!());

@safe:

// ---------------------------------------------------------------------------
// Domain ID value objects
// ---------------------------------------------------------------------------

struct MarketRateId {
  string value;
  this(string v) { value = v; }
  mixin IdTemplate;
}

struct ProviderId {
  string value;
  this(string v) { value = v; }
  mixin IdTemplate;
}

struct AuditLogId {
  string value;
  this(string v) { value = v; }
  mixin IdTemplate;
}
