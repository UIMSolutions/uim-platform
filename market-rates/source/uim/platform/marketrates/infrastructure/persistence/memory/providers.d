/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.marketrates.infrastructure.persistence.memory.providers;
import uim.platform.marketrates;
import std.algorithm : filter;
import std.array     : array;

// mixin(ShowModule!());

@safe:

class MemoryProviderRepository : TentRepository!(Provider, ProviderId), ProviderRepository {

  override Provider findByCode(TenantId t, string code) {
    foreach (p; findByTenant(t))
      if (p.tenantId == t && p.code == code) return p;
    Provider empty; return empty;
  }
  override Provider[] findActive(TenantId t) {
    return findByTenant(t).filter!(p => p.isActive).array;
  }
  override bool codeExists(TenantId t, string code) {
    foreach (p; findByTenant(t))
      if (p.code == code) return true;
    return false;
  }
}
