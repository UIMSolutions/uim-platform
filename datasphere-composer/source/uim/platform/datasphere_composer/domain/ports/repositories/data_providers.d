/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere_composer.domain.ports.repositories.data_providers;

import uim.platform.datasphere_composer;

@safe:
interface DataProviderRepository : ITentRepository!(DataProvider, DataProviderId) {
  DataProvider[] findByStatus(TenantId tenantId, DataProviderStatus status);
}
