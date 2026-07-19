/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.credential_store.infrastructure.persistence.memory.service_bindings;
// import uim.platform.credential_store.domain.entities.service_binding;
// import uim.platform.credential_store.domain.ports.repositories.service_bindings;

 
import uim.platform.credential_store;
mixin(ShowModule!());

@safe:
class MemoryServiceBindingRepository : TenantRepository!(ServiceBinding, ServiceBindingId), ServiceBindingRepository {

  size_t countByClient(TenantId tenantId, string clientId) {
    return findByClient(tenantId, clientId).length;
  }

  ServiceBinding[] findByClient(TenantId tenantId, string clientId) {
    return findByTenant(tenantId).filter!(b => b.clientId == clientId).array; 
  }

  void removeByClient(TenantId tenantId, string clientId) {
    findByClient(tenantId, clientId).each!(b => remove(b));
  }

    // ByStatus
    size_t countByStatus(TenantId tenantId, BindingStatus status) {
        return findByStatus(tenantId, status).length;
    }
    ServiceBinding[] findByStatus(TenantId tenantId, BindingStatus status) {
        return findByTenant(tenantId).filter!(b => b.status == status).array;
    }
    void removeByStatus(TenantId tenantId, BindingStatus status) {
        findByStatus(tenantId, status).each!(b => remove(b));
    }
}
