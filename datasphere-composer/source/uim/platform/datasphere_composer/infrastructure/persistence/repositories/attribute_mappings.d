/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere_composer.infrastructure.persistence.repositories.attribute_mappings;

import uim.platform.datasphere_composer;

mixin(ShowModule!());

@safe:
class MemoryAttributeMappingRepository
    : TenantRepository!(AttributeMapping, AttributeMappingId),
      AttributeMappingRepository {

  AttributeMapping[] findByConfig(TenantId tenantId, DataSourceConfigId configId) {
    AttributeMapping[] result;
    foreach (item; findByTenant(tenantId)) {
      if (item.configId.value == configId.value) result ~= item;
    }
    return result;
  }

  AttributeMapping[] findByTarget(TenantId tenantId, string targetAttributeName) {
    AttributeMapping[] result;
    foreach (item; findByTenant(tenantId)) {
      if (item.targetAttributeName == targetAttributeName) result ~= item;
    }
    return result;
  }
}
