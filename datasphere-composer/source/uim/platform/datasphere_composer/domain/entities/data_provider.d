/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere_composer.domain.entities.data_provider;

import uim.platform.datasphere_composer;

mixin(ShowModule!());

@safe:

/// Represents a data provider that supplies data products (e.g. S/4 HANA Cloud).
struct DataProvider {
  mixin TenantEntity!(DataProviderId);

  string name;
  string description;
  DataProviderStatus status;
  string systemType;       /// e.g. "S4HANA_CLOUD_PRIVATE"
  string connectionUrl;
  string region;
  long   dataProductCount;
  string[string] metadata;

  Json toJson() const {
    return entityToJson()
      .set("name", name)
      .set("description", description)
      .set("status", status.to!string)
      .set("systemType", systemType)
      .set("connectionUrl", connectionUrl)
      .set("region", region)
      .set("dataProductCount", dataProductCount);
  }
}
