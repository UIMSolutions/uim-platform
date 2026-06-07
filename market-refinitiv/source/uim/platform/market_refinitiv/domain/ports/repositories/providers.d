/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.market_refinitiv.domain.ports.repositories.providers;
import uim.platform.market_refinitiv;

// mixin(ShowModule!());

@safe:
interface ProviderRepository : ITenantRepository!(Provider, ProviderId) {

  Provider   findByCode(TenantId tenantId, string code);
  Provider[] findActive(TenantId tenantId);
  bool       codeExists(TenantId tenantId, string code);
}
