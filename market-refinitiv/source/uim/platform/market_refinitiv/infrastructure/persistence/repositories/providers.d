/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.market_refinitiv.infrastructure.persistence.repositories.providers;
import uim.platform.market_refinitiv;
import std.algorithm : filter;
import std.array     : array;

mixin(ShowModule!());

@safe:

class ProviderRepository : TenantRepository!(Provider, ProviderId), IProviderRepository {

  bool codeExists(TenantId tenantId, string code) {
    foreach (p; store.values)
      if (p.tenantId == t && p.code == code) return true;
    return false;
  }

  Provider findByCode(TenantId tenantId, string code) {
    foreach (p; findByTenant(tenantId))
      if (p.code == code) return p;
    return Provider.init;
  }
  
  size_t countActive(TenantId tenantId) {
    return findActive(tenantId).length; 
  }

  Provider[] filterActive(Provider[] providers) {
    return providers.filter!(p => p.isActive).array;
  }

  Provider[] findActive(TenantId tenantId) {
    return filterActive(findByTenant(tenantId));
  }

  void removeActive(TenantId tenantId) {
    findActive(tenantId).eacH!(e => remove(e));
  }
  

}
