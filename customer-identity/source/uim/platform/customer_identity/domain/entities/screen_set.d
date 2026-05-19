/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.customer_identity.domain.entities.screen_set;

import uim.platform.customer_identity;

mixin(ShowModule!());

@safe:

struct ScreenSet {
    mixin TenantEntity!(ScreenSetId);

    string name;
    string description;
    ScreenSetFlowType flowType;
    string htmlContent;
    string cssContent;
    string jsContent;
    string locale;
    string version_;
    ScreenSetStatus status = ScreenSetStatus.draft;

    Json toJson() const {
        return entityToJson
            .set("name", name)
            .set("description", description)
            .set("flowType", flowType.to!string)
            .set("htmlContent", htmlContent)
            .set("cssContent", cssContent)
            .set("jsContent", jsContent)
            .set("locale", locale)
            .set("version", version_)
            .set("status", status.to!string);
    }
}
