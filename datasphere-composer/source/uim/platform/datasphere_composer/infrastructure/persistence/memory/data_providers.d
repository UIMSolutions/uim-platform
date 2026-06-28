/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere_composer.infrastructure.persistence.memory.data_providers;

import uim.platform.datasphere_composer;

// mixin(ShowModule!());

@safe:
class MemoryDataProviderRepository
    : TenantRepository!(DataProvider, DataProviderId),
      DataProviderRepository {

  DataProvider[] findByStatus(TenantId tenantId, DataProviderStatus status) {
    DataProvider[] result;
    foreach (item; find(tenantId)) {
      if (item.status == status) result ~= item;
    }
    return result;
  }
}
