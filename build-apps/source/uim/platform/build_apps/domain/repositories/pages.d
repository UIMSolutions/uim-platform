/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.domain.repositories.pages;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

interface PageRepository {
    bool existsById(PageId id);
    Page findById(PageId id);

    Page[] findAll();
    Page[] findByTenant(TenantId tenantId);
    Page[] findByApplication(ApplicationId applicationId);

    void save(Page entity);
    void update(Page entity);
    void remove(PageId id);
}
