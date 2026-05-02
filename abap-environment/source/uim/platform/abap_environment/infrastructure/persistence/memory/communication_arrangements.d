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
    return findAll().count!(e => e.systemInstanceId == systemId);
  }

  CommunicationArrangement[] findBySystem(SystemInstanceId systemId) {
    return findAll().filter!(e => e.systemInstanceId == systemId).array;
  }

  void removeBySystem(SystemInstanceId systemId) {
    foreach (ca; findBySystem(systemId)) {
      remove(ca.id);
    }
  }
  // #endregion BySystem

  // #region ByDirection
  size_t countByDirection(SystemInstanceId systemId, CommunicationDirection dir) {
    return findAll().count!(e => e.systemInstanceId == systemId && e.direction == dir);
  }

  CommunicationArrangement[] findByDirection(SystemInstanceId systemId, CommunicationDirection dir) {
    return findAll().filter!(e => e.systemInstanceId == systemId && e.direction == dir).array;
  }

  void removeByDirection(SystemInstanceId systemId, CommunicationDirection dir) {
    foreach (ca; findByDirection(systemId, dir)) {
      remove(ca.id);
    }
  }
  // #endregion ByDirection

}
