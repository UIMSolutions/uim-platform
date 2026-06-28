/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.infrastructure.persistence.memory.transport_requests;

// import uim.platform.abap_environment.domain.entities.transport_request;
// import uim.platform.abap_environment.domain.ports.repositories.transport_request;

import uim.platform.abap_environment;

// // mixin(ShowModule!());
@safe:

class MemoryTransportRequestRepository : TenantRepository!(TransportRequest, TransportRequestId), TransportRequestRepository {

  // #region BySystem
  size_t countBySystem(TenantId tenantId, SystemInstanceId systemId) {
    return findBySystem(tenantId, systemId).length;
  }

  TransportRequest[] filterBySystem(TransportRequest[] requests, SystemInstanceId systemId) {
    return requests.filter!(e => e.sourceSystemId == systemId).array;
  }

  TransportRequest[] findBySystem(TenantId tenantId, SystemInstanceId systemId) {
    return filterBySystem(find(tenantId), systemId);
  }

  void removeBySystem(TenantId tenantId, SystemInstanceId systemId) {
    findBySystem(tenantId, systemId).each!(e => remove(e));
  }
  // #endregion BySystem

  // #region ByStatus
  size_t countByStatus(TenantId tenantId, SystemInstanceId systemId, TransportStatus status) {
    return findByStatus(tenantId, systemId, status).length;
  }

TransportRequest[] filterByStatus(  TransportRequest[] requests, TransportStatus status) {
    return requests.filter!(e => e.status == status).array;
  }

  TransportRequest[] findByStatus(TenantId tenantId, SystemInstanceId systemId, TransportStatus status) {
    return filterByStatus(filterBySystem(find(tenantId), systemId), status);
  }

  void removeByStatus(TenantId tenantId, SystemInstanceId systemId, TransportStatus status) {
    findByStatus(tenantId, systemId, status).each!(e => remove(e));
  }
  // #endregion ByStatus

  // #region ByOwner
  size_t countByOwner(TenantId tenantId, SystemInstanceId systemId, string owner) {
    return findByOwner(tenantId, systemId, owner).length;
  }

  TransportRequest[] filterByOwner(TransportRequest[] requests, string owner) {
    return requests.filter!(e => e.owner == owner).array;
  }

  TransportRequest[] findByOwner(TenantId tenantId, SystemInstanceId systemId, string owner) {
    return filterByOwner(findBySystem(tenantId, systemId), owner);
  }

  void removeByOwner(TenantId tenantId, SystemInstanceId systemId, string owner) {
    findByOwner(tenantId, systemId, owner).each!(e => remove(e));
  }
  // #endregion ByOwner

}
