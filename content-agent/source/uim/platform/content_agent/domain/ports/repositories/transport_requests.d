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
  TransportRequest findById(TransportRequestId id);
  TransportRequest[] findByTenant(TenantId tenantId);
  TransportRequest[] findByStatus(TenantId tenantId, TransportStatus status);
  void save(TransportRequest request);
  void update(TransportRequest request);
  void remove(TransportRequestId id);
}
