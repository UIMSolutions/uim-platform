/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere_composer.infrastructure.persistence.memory.customer_profiles;

import uim.platform.datasphere_composer;
mixin(ShowModule!());

@safe:
class MemoryCustomerProfileRepository
    : TenantRepository!(CustomerProfile, CustomerProfileId),
      CustomerProfileRepository {

  CustomerProfile[] findByEmail(TenantId tenantId, string email) {
    CustomerProfile[] result;
    foreach (item; findByTenant(tenantId)) {
      if (item.email == email) result ~= item;
    }
    return result;
  }

  CustomerProfile[] findByExternalId(TenantId tenantId, string externalId) {
    CustomerProfile[] result;
    foreach (item; findByTenant(tenantId)) {
      if (item.externalId == externalId) result ~= item;
    }
    return result;
  }
}
