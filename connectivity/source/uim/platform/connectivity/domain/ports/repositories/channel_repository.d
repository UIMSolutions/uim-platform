/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.domain.ports.channel_repository;

import uim.platform.connectivity.domain.entities.service_channel;
import uim.platform.connectivity.domain.types;

/// Port: outgoing - service channel persistence.
interface ChannelRepository
{
  ServiceChannel findById(ChannelId id);
  ServiceChannel[] findByConnector(ConnectorId connectorId);
  ServiceChannel[] findByTenant(TenantId tenantId);
  ServiceChannel[] findByStatus(TenantId tenantId, ChannelStatus status);
  void save(ServiceChannel channel);
  void update(ServiceChannel channel);
  void remove(ChannelId id);
}
