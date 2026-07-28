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

class MemoryProviderRepository : ProviderRepository {
  private Provider[string] store;

  override Provider   findById(TenantId t, ProviderId id) {
    if (auto p = id.value in store) return *p;
    Provider empty; return empty;
  }
  override Provider[] findByTenant(TenantId t) {
    return store.values.filter!(p => p.tenantId == t).array;
  }
  override void save(Provider p)   { store[p.id.value] = p; }
  override void update(Provider p) { store[p.id.value] = p; }
  override void remove(Provider p) { store.remove(p.id.value); }

  override Provider findByCode(TenantId t, string code) {
    foreach (p; store.values)
      if (p.tenantId == t && p.code == code) return p;
    Provider empty; return empty;
  }
  override Provider[] findActive(TenantId t) {
    return store.values.filter!(p => p.tenantId == t && p.isActive).array;
  }
  override bool codeExists(TenantId t, string code) {
    foreach (p; store.values)
      if (p.tenantId == t && p.code == code) return true;
    return false;
  }
}
