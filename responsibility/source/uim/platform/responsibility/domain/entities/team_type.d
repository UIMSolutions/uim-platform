/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.responsibility.domain.entities.team_type;

import uim.platform.responsibility;

// mixin(ShowModule!());

@safe:

/// Team type provides a finer classification within a TeamCategory
/// (e.g. "Cost-Center Team" within "Finance").
struct TeamType {
    mixin TenantEntity!(TeamTypeId);

    string name;
    string description;
    string code;
    string categoryId;     // linked TeamCategoryId value

    Json toJson() const {
        return entityToJson
            .set("name",        name)
            .set("description", description)
            .set("code",        code)
            .set("categoryId",  categoryId);
    }
}
