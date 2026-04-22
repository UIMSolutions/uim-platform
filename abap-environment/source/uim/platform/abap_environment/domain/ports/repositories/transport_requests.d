/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.domain.ports.repositories.transport_requests;

import uim.platform.abap_environment.domain.entities.transport_request;
import uim.platform.abap_environment.domain.types;

/// Port: outgoing - transport request persistence.
interface TransportRequestRepository : ITenantRepository!(TransportRequest, TransportRequestId) {

  size_t countBySystem(SystemInstanceId systemId);
  TransportRequest[] findBySystem(SystemInstanceId systemId);
  void removeBySystem(SystemInstanceId systemId);

  size_t countByStatus(SystemInstanceId systemId, TransportStatus status);
  TransportRequest[] findByStatus(SystemInstanceId systemId, TransportStatus status);
  void removeByStatus(SystemInstanceId systemId, TransportStatus status);

  size_t countByOwner(SystemInstanceId systemId, string owner);
  TransportRequest[] findByOwner(SystemInstanceId systemId, string owner);
  void removeByOwner(SystemInstanceId systemId, string owner);

}
