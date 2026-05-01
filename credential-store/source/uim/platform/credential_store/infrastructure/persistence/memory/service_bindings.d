/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.credential_store.infrastructure.persistence.memory.service_bindings;

// import uim.platform.credential_store.domain.entities.service_binding;
// import uim.platform.credential_store.domain.ports.repositories.service_bindings;
// import uim.platform.credential_store.domain.types;

// import std.algorithm : filter;
// import std.array : array;
import uim.platform.credential_store;

mixin(ShowModule!());

@safe:
class MemoryServiceBindingRepository : TenantRepository!(ServiceBinding, ServiceBindingId), ServiceBindingRepository {

  size_t countByClientId(string clientId) {
    return findByClientId(clientId).length;
  }

  ServiceBinding[] findByClientId(string clientId) {
    return findAll.filter!(b => b.clientId == clientId).array; 
  }

  void removeByClientId(string clientId) {
    findByClientId(clientId).each!(b => remove(b));
  }

    // ByStatus
    size_t countByStatus(BindingStatus status) {
        return findByStatus(status).length;
    }
    ServiceBinding[] findByStatus(BindingStatus status) {
        return findAll.filter!(b => b.status == status).array;
    }
    void removeByStatus(BindingStatus status) {
        findByStatus(status).each!(b => remove(b));
    }
}
