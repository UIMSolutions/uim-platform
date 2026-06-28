/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere_composer.infrastructure.persistence.memory.data_source_configs;

import uim.platform.datasphere_composer;

// mixin(ShowModule!());

@safe:
class MemoryDataSourceConfigRepository
    : TenantRepository!(DataSourceConfig, DataSourceConfigId),
      DataSourceConfigRepository {

  DataSourceConfig[] findByProduct(TenantId tenantId, DataProductId productId) {
    DataSourceConfig[] result;
    foreach (item; find(tenantId)) {
      if (item.dataProductId.value == productId.value) result ~= item;
    }
    return result;
  }

  DataSourceConfig[] findEnabled(TenantId tenantId) {
    DataSourceConfig[] result;
    foreach (item; find(tenantId)) {
      if (item.enabled) result ~= item;
    }
    return result;
  }
}
