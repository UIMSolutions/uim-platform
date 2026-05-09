/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.authentication.infrastructure.persistence.memory.applications;

// import uim.platform.identity.authentication.domain.entities.application;
// import uim.platform.identity.authentication.domain.types;
// import uim.platform.identity.authentication.domain.ports.repositories.application;

import uim.platform.identity.authentication;

mixin(ShowModule!());
@safe:
/// In-memory adapter for application/service provider persistence.
class MemoryApplicationRepository : ApplicationRepository {
  
  bool existsByClientId(string clientId) {
    foreach (a; findAll()) {
      if (a.clientId == clientId)
        return true;
    }
    return false;
  }

  Application findByClientId(string clientId) {
    foreach (a; findAll()) {
      if (a.clientId == clientId)
        return a;
    }
    return Application.init;
  }

}
