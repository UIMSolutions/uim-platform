/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.service_manager.infrastructure.persistence.repositories.service_bindings;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class ServiceBindingRepository : TenantRepository!(ServiceBinding, ServiceBindingId), IServiceBindingRepository {

    size_t countByStatus(TenantId tenantId, ServiceBindingStatus status) {
        return this.findByStatus(tenantId, status).length;
    }
    ServiceBinding[] filterByStatus(ServiceBinding[] bindings, ServiceBindingStatus status) {
        return bindings.filter!(b => b.status == status).array;
    }
    ServiceBinding[] findByStatus(TenantId tenantId, ServiceBindingStatus status) {
        return this.filterByStatus(this.findByTenant(tenantId), status);
    }
    void removeByStatus(TenantId tenantId, ServiceBindingStatus status)     {
        this.findByStatus(tenantId, status).each!(b => this.remove(b));
    }

}

///
unittest {
    assert(tenantRepositoryTest(new ServiceBindingRepository()));
}
