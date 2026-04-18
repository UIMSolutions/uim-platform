/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.domain.repositories.service_bindings;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

interface ServiceBindingRepository {
    bool existsById(ServiceBindingId id);
    ServiceBinding findById(ServiceBindingId id);

    ServiceBinding[] findAll();
    ServiceBinding[] findByTenant(TenantId tenantId);
    ServiceBinding[] findByDevSpace(DevSpaceId devSpaceId);
    ServiceBinding[] findByStatus(BindingStatus status);

    void save(ServiceBinding entity);
    void update(ServiceBinding entity);
    void remove(ServiceBindingId id);
}
