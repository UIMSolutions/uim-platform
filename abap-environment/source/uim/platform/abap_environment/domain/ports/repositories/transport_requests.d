/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.domain.ports.repositories.transport_requests;
// import uim.platform.abap_environment.domain.entities.transport_request;
// import uim.platform.abap_environment.domain.types;
import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:
/// Port: outgoing - transport request persistence.
interface TransportRequestRepository : ITenantRepository!(TransportRequest, TransportRequestId) {

  size_t countBySystem(TenantId tenantId, SystemInstanceId systemId);
  TransportRequest[] findBySystem(TenantId tenantId, SystemInstanceId systemId);
  void removeBySystem(TenantId tenantId, SystemInstanceId systemId);

  size_t countByStatus(TenantId tenantId, SystemInstanceId systemId, TransportStatus status);
  TransportRequest[] findByStatus(TenantId tenantId, SystemInstanceId systemId, TransportStatus status);
  void removeByStatus(TenantId tenantId, SystemInstanceId systemId, TransportStatus status);

  size_t countByOwner(TenantId tenantId, SystemInstanceId systemId, string owner);
  TransportRequest[] findByOwner(TenantId tenantId, SystemInstanceId systemId, string owner);
  void removeByOwner(TenantId tenantId, SystemInstanceId systemId, string owner);

}
