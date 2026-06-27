/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.infrastructure.persistence.memory.connectors;
// import uim.platform.connectivity.domain.types;
// import uim.platform.connectivity.domain.entities.cloud_connector;
// import uim.platform.connectivity.domain.ports.repositories.connectors;
import uim.platform.connectivity;

// mixin(ShowModule!());

@safe:
class MemoryConnectorRepository : TentRepository!(CloudConnector, ConnectorId), ConnectorRepository {
 
  bool existsByLocation(TenantId tenantId, SubaccountId subaccountId, string locationId) {
    return findByTenant(tenantId).any!(e => e.subaccountId == subaccountId && e.locationId == locationId);
  }

  CloudConnector findByLocation(TenantId tenantId, SubaccountId subaccountId, string locationId) {
    foreach (e; findByTenant(tenantId))
      if (e.subaccountId == subaccountId && e.locationId == locationId)
        return e;
    return CloudConnector.init;
  }

  void removeByLocation(TenantId tenantId, SubaccountId subaccountId, string locationId) {
    foreach (e; findByTenant(tenantId))
      if (e.subaccountId == subaccountId && e.locationId == locationId)
         return remove(e);
  }

  size_t countBySubaccount(TenantId tenantId, SubaccountId subaccountId) {
    return findBySubaccount(tenantId, subaccountId).length;
  }

  CloudConnector[] findBySubaccount(TenantId tenantId, SubaccountId subaccountId) {
    return findByTenant(tenantId).filter!(e => e.subaccountId == subaccountId).array;
  }

  void removeBySubaccount(TenantId tenantId, SubaccountId subaccountId) {
    findBySubaccount(tenantId, subaccountId).each!(e => remove(e));
  }

}
