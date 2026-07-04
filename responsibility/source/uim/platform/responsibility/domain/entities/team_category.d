/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.responsibility.domain.entities.team_category;

import uim.platform.responsibility;

mixin(ShowModule!());

@safe:

/// Team category groups teams into high-level domains (e.g. Finance, HR, Operations).
struct TeamCategory {
    mixin TenantEntity!(TeamCategoryId);

    string name;
    string description;
    string code;              // short unique code (e.g. "FIN", "HR")

    Json toJson() const {
        return entityToJson
            .set("name",        name)
            .set("description", description)
            .set("code",        code);
    }
}
