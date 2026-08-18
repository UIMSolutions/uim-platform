/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.domain.ports.usecases.pages;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

interface IManagePagesUseCase { 

    Page getPage(TenantId tenantId, PageId id);
    Page[] listPages(TenantId tenantId);
    Page[] listPages(TenantId tenantId, ApplicationId applicationId);
    UsecaseResult createPage(PageDTO dto);
    UsecaseResult updatePage(PageDTO dto);
    UsecaseResult deletePage(TenantId tenantId, PageId id);
    
}
