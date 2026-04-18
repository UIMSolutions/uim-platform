/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_enviroment.domain.ports.repositories.transport_requests;

import uim.platform.abap_enviroment.domain.entities.transport_request;
import uim.platform.abap_enviroment.domain.types;

/// Port: outgoing - transport request persistence.
interface TransportRequestRepository : ITenantRepository!(TransportRequest, TransportRequestId) {
  // TransportRequest* findById(TransportRequestId id);
  TransportRequest[] findBySystem(SystemInstanceId systemId);
  // TransportRequest[] findByTenant(TenantId tenantId);
  TransportRequest[] findByStatus(SystemInstanceId systemId, TransportStatus status);
  TransportRequest[] findByOwner(SystemInstanceId systemId, string owner);
  // void save(TransportRequest request);
  // void update(TransportRequest request);
  // void remove(TransportRequestId id);
}
