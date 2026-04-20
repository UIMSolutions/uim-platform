/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.domain.entities.branding_config;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

struct BrandingConfig {
    mixin TenantEntity!(BrandingConfigId);
    
    string name;
    string description;
    string logoUrl;
    string backgroundUrl;
    string primaryColor;
    string secondaryColor;
    string pageTitle;
    string footerText;
    string customCss;

    Json toJson() const {
        return entityToJson
            .set("name", name)
            .set("description", description)
            .set("logoUrl", logoUrl)
            .set("backgroundUrl", backgroundUrl)
            .set("primaryColor", primaryColor)
            .set("secondaryColor", secondaryColor)
            .set("pageTitle", pageTitle)
            .set("footerText", footerText)
            .set("customCss", customCss);
    }
}
