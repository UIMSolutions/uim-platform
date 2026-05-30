/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.domain.entities.formation;

import uim.platform.service;
import uim.platform.appevents.domain.valueobjects;
import uim.platform.appevents.domain.enums.formation_status;


@safe:

struct Formation {
    mixin TenantEntity!(FormationId);

    string name;
    string description;
    string globalAccountId;
    FormationStatus status;
    int systemCount = 0;

    Json toJson() const @safe {
        return Json.emptyObject
            .set("id",              id.value)
            .set("tenantId",        tenantId.value)
            .set("name",            name)
            .set("description",     description)
            .set("globalAccountId", globalAccountId)
            .set("status",          status.to!string)
            .set("systemCount",     systemCount)
            .set("createdAt",       createdAt)
            .set("createdBy",       createdBy.value)
            .set("updatedAt",       updatedAt)
            .set("updatedBy",       updatedBy.value);
    }
}
