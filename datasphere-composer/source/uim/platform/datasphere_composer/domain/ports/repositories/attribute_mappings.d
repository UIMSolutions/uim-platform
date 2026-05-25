/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere_composer.domain.ports.repositories.attribute_mappings;

import uim.platform.datasphere_composer;

@safe:
interface AttributeMappingRepository : ITenantRepository!(AttributeMapping, AttributeMappingId) {
  AttributeMapping[] findByConfig(TenantId tenantId, DataSourceConfigId configId);
  AttributeMapping[] findByTarget(TenantId tenantId, string targetAttributeName);
}
