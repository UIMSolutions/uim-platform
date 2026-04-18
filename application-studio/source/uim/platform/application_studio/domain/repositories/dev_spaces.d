/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.domain.repositories.dev_spaces;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

interface DevSpaceRepository {
    bool existsById(DevSpaceId id);
    DevSpace findById(DevSpaceId id);

    DevSpace[] findAll();
    DevSpace[] findByTenant(TenantId tenantId);
    DevSpace[] findByOwner(string owner);
    DevSpace[] findByStatus(DevSpaceStatus status);

    void save(DevSpace entity);
    void update(DevSpace entity);
    void remove(DevSpaceId id);
}
