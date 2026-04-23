/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.infrastructure.persistence.memory.destinations;

// import uim.platform.connectivity.domain.types;
// import uim.platform.connectivity.domain.entities.destination;
// import uim.platform.connectivity.domain.ports.repositories.destinations;
// 
// // import std.algorithm : filter;
// // import std.array : array;
import uim.platform.connectivity;

mixin(ShowModule!());

@safe:
class MemoryDestinationRepository : TenantRepository!(Destination, DestinationId), DestinationRepository {

  // #region ByName
  bool existsByName(TenantId tenantId, string name) {
    findByTenant(tenantId).any!(e => e.name == name);
  }

  Destination findByName(TenantId tenantId, string name) {
    foreach (e; findByTenant(tenantId)) {
      if (e.name == name)
        return e;
    }
    return Destination.init;
  }

  void removeByName(TenantId tenantId, string name) {
    foreach (e; findByTenant(tenantId)) {
      if (e.name == name)
        return remove(e);
    }
  }
  // #endregion ByName

  // #region ByProxyType
  size_t countByProxyType(TenantId tenantId, ProxyType proxyType) {
    return findByProxyType(tenantId, proxyType).length;
  }

  Destination[] findByProxyType(TenantId tenantId, ProxyType proxyType) {
    return findByTenant(tenantId).filter!(e => e.proxyType == proxyType).array;
  }

  void removeByProxyType(TenantId tenantId, ProxyType proxyType) {
    findByProxyType(tenantId, proxyType).each!(e => remove(e));
  }
  // #endregion ByProxyType

}
