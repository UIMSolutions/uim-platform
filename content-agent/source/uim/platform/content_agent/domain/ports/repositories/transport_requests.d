/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.content_agent.domain.ports.repositories.transport_requests;

import uim.platform.content_agent.domain.entities.transport_request;
import uim.platform.content_agent.domain.types;

/// Port: outgoing - transport request persistence.
interface TransportRequestRepository {

  size_t countByTenant(TenantId tenantId);
  TransportRequest[] findByTenant(TenantId tenantId);
  void removeByTenant(TenantId tenantId);

  size_t countByStatus(TenantId tenantId, TransportStatus status);
  TransportRequest[] findByStatus(TenantId tenantId, TransportStatus status);
  void removeByStatus(TenantId tenantId, TransportStatus status);

}
