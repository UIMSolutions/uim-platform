/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere_composer.infrastructure.persistence.memory.data_products;

import uim.platform.datasphere_composer;
mixin(ShowModule!());

@safe:
class MemoryDataProductRepository
    : TenantRepository!(DataProduct, DataProductId),
      DataProductRepository {

  DataProduct[] findByProvider(TenantId tenantId, DataProviderId providerId) {
    DataProduct[] result;
    foreach (item; findByTenant(tenantId)) {
      if (item.providerId.value == providerId.value) result ~= item;
    }
    return result;
  }

  DataProduct[] findEnabled(TenantId tenantId) {
    DataProduct[] result;
    foreach (item; findByTenant(tenantId)) {
      if (item.enabled) result ~= item;
    }
    return result;
  }
}
