/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.infrastructure.persistence.memory
  .communication_arrangements;

// import uim.platform.abap_environment.domain.types;
// import uim.platform.abap_environment.domain.entities.communication_arrangement;
// import uim.platform.abap_environment.domain.ports.repositories.communication_arrangements;

// import std.algorithm : filter;
// import std.array : array;
import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:
class MemoryCommunicationArrangementRepository : TenantRepository!(CommunicationArrangement, CommunicationArrangementId), CommunicationArrangementRepository {
  
  // #region BySystem
  size_t countBySystem(SystemInstanceId systemId) {
    return findBySystem(systemId).length;
  }

  CommunicationArrangement[] filterBySystem(CommunicationArrangement[] arrangements, SystemInstanceId systemId) {
    return arrangements.filter!(e => e.systemInstanceId == systemId).array;
  }
  
  CommunicationArrangement[] findBySystem(SystemInstanceId systemId) {
    return findAll().filterBySystem(systemId);
  }

  void removeBySystem(SystemInstanceId systemId) {
    findBySystem(systemId).each!(ca => remove(ca));
  }
  // #endregion BySystem

  // #region ByDirection
  size_t countByDirection(SystemInstanceId systemId, CommunicationDirection dir) {
    return findBySystem(systemId).count!(e => e.direction == dir);
  }

  CommunicationArrangement[] filterByDirection(CommunicationArrangement[] arrangements, CommunicationDirection dir) {
    return arrangements.filter!(e => e.direction == dir).array;
  }

  CommunicationArrangement[] findByDirection(SystemInstanceId systemId, CommunicationDirection dir) {
    return findBySystem(systemId).filterByDirection(dir);
  }

  void removeByDirection(SystemInstanceId systemId, CommunicationDirection dir) {
    findByDirection(systemId, dir).each!(ca => remove(ca));
  }
  // #endregion ByDirection

}
