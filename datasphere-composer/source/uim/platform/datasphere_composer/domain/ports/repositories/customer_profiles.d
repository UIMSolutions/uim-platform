/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere_composer.domain.ports.repositories.customer_profiles;

import uim.platform.datasphere_composer;

@safe:
interface CustomerProfileRepository : ITentRepository!(CustomerProfile, CustomerProfileId) {
  CustomerProfile[] findByEmail(TenantId tenantId, string email);
  CustomerProfile[] findByExternalId(TenantId tenantId, string externalId);
}
