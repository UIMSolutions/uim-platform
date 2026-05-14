/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.infrastructure.persistence.memory.channels;

// import uim.platform.connectivity.domain.types;
// import uim.platform.connectivity.domain.entities.service_channel;
// import uim.platform.connectivity.domain.ports.repositories.channels;
// 
// 
//  

import uim.platform.connectivity;

mixin(ShowModule!());

@safe:

class MemoryChannelRepository : TenantRepository!(ServiceChannel, ChannelId), ChannelRepository {

  size_t countByConnector(TenantId tenantId, ConnectorId connectorId) {
    return findByConnector(tenantId, connectorId).length;
  }

  ServiceChannel[] findByConnector(TenantId tenantId, ConnectorId connectorId) {
    return findByTenant(tenantId).filter!(e => e.connectorId == connectorId).array;
  }

  void removeByConnector(TenantId tenantId, ConnectorId connectorId) {
    findByConnector(tenantId, connectorId).each!(e => remove(e));
  }

  size_t countByStatus(TenantId tenantId, ChannelStatus status) {
    return findByStatus(tenantId, status).length;
  }

  ServiceChannel[] findByStatus(TenantId tenantId, ChannelStatus status) {
    return findByTenant(tenantId).filter!(e => e.status == status).array;
  }

  void removeByStatus(TenantId tenantId, ChannelStatus status) {
    findByStatus(tenantId, status).each!(e => remove(e));
  }

}
