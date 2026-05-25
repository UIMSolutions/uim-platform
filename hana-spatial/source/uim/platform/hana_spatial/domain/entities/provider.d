/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana_spatial.domain.entities.provider;

import uim.platform.hana_spatial;

mixin(ShowModule!());

@safe:

struct Provider {
  mixin TenantEntity!(ProviderId);

  string name;
  string description;
  ProviderType type;
  ProviderStatus status;
  string apiKey;
  string baseUrl;
  bool supportsGeocoding;
  bool supportsRouting;
  bool supportsMapping;
  bool supportsIsoline;
  bool supportsPoi;
  string[] supportedRegions;
  string[][] config;

  Json toJson() const {
    auto regArr = Json.emptyArray;
    foreach (r; supportedRegions) regArr ~= Json(r);

    return entityToJson()
      .set("name", name)
      .set("description", description)
      .set("type", type.to!string)
      .set("status", status.to!string)
      .set("baseUrl", baseUrl)
      .set("supportsGeocoding", supportsGeocoding)
      .set("supportsRouting", supportsRouting)
      .set("supportsMapping", supportsMapping)
      .set("supportsIsoline", supportsIsoline)
      .set("supportsPoi", supportsPoi)
      .set("supportedRegions", regArr);
  }
}
