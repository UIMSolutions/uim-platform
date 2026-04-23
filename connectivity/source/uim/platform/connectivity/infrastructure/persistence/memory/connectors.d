/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.infrastructure.persistence.memory.connectors;

// import uim.platform.connectivity.domain.types;
// import uim.platform.connectivity.domain.entities.cloud_connector;
// import uim.platform.connectivity.domain.ports.repositories.connectors;
// 
// // import std.algorithm : filter;
// // import std.array : array;
import uim.platform.connectivity;

mixin(ShowModule!());

@safe:
class MemoryConnectorRepository : TenantRepository!(CloudConnector, ConnectorId), ConnectorRepository {
 
  bool existsByLocationId(SubaccountId subaccountId, string locationId) {
    return findAll.any!(e => e.subaccountId == subaccountId && e.locationId == locationId);
  }

  CloudConnector findByLocationId(SubaccountId subaccountId, string locationId) {
    foreach (e; findAll)
      if (e.subaccountId == subaccountId && e.locationId == locationId)
        return e;
    return CloudConnector.init;
  }

  void removeByLocationId(SubaccountId subaccountId, string locationId) {
    foreach (e; findAll)
      if (e.subaccountId == subaccountId && e.locationId == locationId)
         return remove(e);
  }

  size_t countBySubaccount(SubaccountId subaccountId) {
    return findBySubaccount(subaccountId).length;
  }

  CloudConnector[] findBySubaccount(SubaccountId subaccountId) {
    return findAll.filter!(e => e.subaccountId == subaccountId).array;
  }

  void removeBySubaccount(SubaccountId subaccountId) {
    findBySubaccount(subaccountId).each!(e => remove(e));
  }

}
