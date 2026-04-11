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
class MemoryConnectorRepository : MemoryTenantRepository!(CloudConnector, ConnectorId), ConnectorRepository {
  CloudConnector findByLocationId(SubaccountId subaccountId, string locationId) {
    foreach (e; store.byValue())
      if (e.subaccountId == subaccountId && e.locationId == locationId)
        return e;
    return CloudConnector.init;
  }

  CloudConnector[] findBySubaccount(SubaccountId subaccountId) {
    return store.byValue().filter!(e => e.subaccountId == subaccountId).array;
  }
}
