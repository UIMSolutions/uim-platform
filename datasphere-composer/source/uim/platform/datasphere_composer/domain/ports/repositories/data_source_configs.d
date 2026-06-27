/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere_composer.domain.ports.repositories.data_source_configs;

import uim.platform.datasphere_composer;

@safe:
interface DataSourceConfigRepository : ITenantRepository!(DataSourceConfig, DataSourceConfigId) {
  DataSourceConfig[] findByProduct(TenantId tenantId, DataProductId productId);
  DataSourceConfig[] findEnabled(TenantId tenantId);
}
