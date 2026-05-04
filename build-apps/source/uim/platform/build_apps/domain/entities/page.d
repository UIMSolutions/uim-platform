/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.domain.entities.page;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

struct Page {
    PageId id;
    TenantId tenantId;
    ApplicationId applicationId;
    string name;
    string description;
    PageType pageType = PageType.blank;
    string route;
    string layoutConfig;
    string componentTree;
    string styleOverrides;
    string pageVariables;
    int sortOrder;
    bool isStartPage;
    long createdAt;
    long updatedAt;
    UserId createdBy;
    UserId updatedBy;

    Json pageToJson() {
        return Json.emptyObject
            .set("id", id)
            .set("tenantId", tenantId)
            .set("applicationId", applicationId)
            .set("name", name)
            .set("description", description)
            .set("pageType", pageType.to!string)
            .set("route", route)
            .set("layoutConfig", layoutConfig)
            .set("componentTree", componentTree)
            .set("styleOverrides", styleOverrides)
            .set("pageVariables", pageVariables)
            .set("sortOrder", sortOrder)
            .set("isStartPage", isStartPage)
            .set("createdAt", createdAt)
            .set("updatedAt", updatedAt)
            .set("createdBy", createdBy)
            .set("updatedBy", updatedBy);
    }
}
