/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.credential_store.domain.ports.repositories.service_bindings;

// import uim.platform.credential_store.domain.entities.service_binding;
// import uim.platform.credential_store.domain.types;

import uim.platform.credential_store;

mixin(ShowModule!());

@safe:
interface ServiceBindingRepository : ITenantRepository!(ServiceBinding, ServiceBindingId) {
    size_t countByClientId(TenantId tenantId, string clientId);
    ServiceBinding[] findByClientId(TenantId tenantId, string clientId);
    void removeByClientId(TenantId tenantId, string clientId);

    // ByStatus
    size_t countByStatus(TenantId tenantId, BindingStatus status);
    ServiceBinding[] findByStatus(TenantId tenantId, BindingStatus status);
    void removeByStatus(TenantId tenantId, BindingStatus status);
}
    