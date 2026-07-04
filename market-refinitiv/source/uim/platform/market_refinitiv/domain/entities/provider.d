/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.market_refinitiv.domain.entities.provider;
import uim.platform.market_refinitiv;

mixin(ShowModule!());

@safe:

// A market data provider (e.g. ECB, Thomson Reuters)
struct Provider {
  mixin TenantEntity!(ProviderId);

  string code;         // Short unique code used in upload payloads
  string name;         // Human-readable name
  string description;
  string contactEmail;
  bool   isActive;

  Json toJson() const {
    return entityToJson
      .set("code",         code)
      .set("name",         name)
      .set("description",  description)
      .set("contactEmail", contactEmail)
      .set("isActive",     isActive);
  }
}
