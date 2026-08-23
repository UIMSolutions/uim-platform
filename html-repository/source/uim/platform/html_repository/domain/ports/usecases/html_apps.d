/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.domain.ports.usecases.html_apps;

import uim.platform.html_repository;

mixin(ShowModule!());

@safe:

interface IManageHtmlAppsUseCase {

    UsecaseResult createApp(CreateHtmlAppRequest r);

    UsecaseResult updateApp(UpdateHtmlAppRequest r);

    HtmlApp getApp(TenantId tenantId, HtmlAppId id);

    HtmlApp[] listApps(TenantId tenantId);

    HtmlApp[] listPublicApps(TenantId tenantId);

    UsecaseResult deleteApp(TenantId tenantId, HtmlAppId id);

    size_t countApps(TenantId tenantId);

}
