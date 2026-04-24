/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.credential_store.infrastructure.persistence.memory.service_binding;

import uim.platform.credential_store.domain.entities.service_binding;
import uim.platform.credential_store.domain.ports.repositories.service_bindings;
import uim.platform.credential_store.domain.types;

import std.algorithm : filter;
import std.array : array;

class MemoryServiceBindingRepository : TenantRepository!(ServiceBinding, ServiceBindingId), ServiceBindingRepository {

  bool existsByClientId(string clientId) {
    foreach (b; store) {
      if (b.clientId == clientId)
        return true;
    }
    return false;
  }

  ServiceBinding findByClientId(string clientId) {
    foreach (b; store) {
      if (b.clientId == clientId)
        return b;
    }
    return ServiceBinding.init;
  }

  void removeByClientId(string clientId) {
    ServiceBinding b = findByClientId(clientId);
    if (b.id.value != "")
      remove(b.id);
  }

}
