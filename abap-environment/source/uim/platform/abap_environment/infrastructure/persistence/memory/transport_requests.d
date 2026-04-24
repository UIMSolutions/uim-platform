/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.infrastructure.persistence.memory.transport_request;

// import uim.platform.abap_environment.domain.types;
// import uim.platform.abap_environment.domain.entities.transport_request;
// import uim.platform.abap_environment.domain.ports.repositories.transport_request;
// 
// // import std.algorithm : filter;
// // import std.array : array;

import uim.platform.abap_environment;

mixin(ShowModule!());
@safe:

class MemoryTransportRequestRepository : TenantRepository!(TransportRequest, TransportRequestId), TransportRequestRepository {

  // #region BySystem
  size_t countBySystem(SystemInstanceId systemId) {
    return findBySystem(systemId).length;
  }

  TransportRequest[] findBySystem(SystemInstanceId systemId) {
    return findAll().filter!(e => e.sourceSystemId == systemId).array;
  }

  void removeBySystem(SystemInstanceId systemId) {
    findBySystem(systemId).each!(e => remove(e));
  }
  // #endregion BySystem

  // #region ByStatus
  size_t countByStatus(SystemInstanceId systemId, TransportStatus status) {
    return findByStatus(systemId, status).length;
  }

  TransportRequest[] findByStatus(SystemInstanceId systemId, TransportStatus status) {
    return findAll().filter!(e => e.sourceSystemId == systemId && e.status == status).array;
  }

  void removeByStatus(SystemInstanceId systemId, TransportStatus status) {
    findByStatus(systemId, status).each!(e => remove(e));
  }
  // #endregion ByStatus

  // #region ByOwner
  size_t countByOwner(SystemInstanceId systemId, string owner) {
    return findByOwner(systemId, owner).length;
  }

  TransportRequest[] findByOwner(SystemInstanceId systemId, string owner) {
    return findAll().filter!(e => e.sourceSystemId == systemId && e.owner == owner).array;
  }

  void removeByOwner(SystemInstanceId systemId, string owner) {
    findByOwner(systemId, owner).each!(e => remove(e));
  }
  // #endregion ByOwner

}
