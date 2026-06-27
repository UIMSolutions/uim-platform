/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.infrastructure.persistence.memory
  .communication_arrangements;

// import uim.platform.abap_environment.domain.entities.communication_arrangement;
// import uim.platform.abap_environment.domain.ports.repositories.communication_arrangements;
 
import uim.platform.abap_environment;

// // mixin(ShowModule!());

@safe:
class MemoryCommunicationArrangementRepository : TenantRepository!(CommunicationArrangement, CommunicationArrangementId), CommunicationArrangementRepository {
  
  // #region BySystem
  size_t countBySystem(TenantId tenantId, SystemInstanceId systemId) {
    return findBySystem(tenantId, systemId).length;
  }

  CommunicationArrangement[] filterBySystem(CommunicationArrangement[] arrangements, SystemInstanceId systemId) {
    return arrangements.filter!(e => e.systemInstanceId == systemId).array;
  }
  
  CommunicationArrangement[] findBySystem(TenantId tenantId, SystemInstanceId systemId) {
    return filterBySystem(findByTenant(tenantId), systemId);
  }

  void removeBySystem(TenantId tenantId, SystemInstanceId systemId) {
    findBySystem(tenantId, systemId).each!(ca => remove(ca));
  }
  // #endregion BySystem

  // #region ByDirection
  size_t countByDirection(TenantId tenantId, SystemInstanceId systemId, CommunicationDirection dir) {
    return findByDirection(tenantId, systemId, dir).length;
  }

  CommunicationArrangement[] filterByDirection(CommunicationArrangement[] arrangements, CommunicationDirection dir) {
    return arrangements.filter!(e => e.direction == dir).array;
  }

  CommunicationArrangement[] findByDirection(TenantId tenantId, SystemInstanceId systemId, CommunicationDirection dir) {
    return filterByDirection(findBySystem(tenantId, systemId), dir);
  }

  void removeByDirection(TenantId tenantId, SystemInstanceId systemId, CommunicationDirection dir) {
    findByDirection(tenantId, systemId, dir).each!(ca => remove(ca));
  }
  // #endregion ByDirection

}
