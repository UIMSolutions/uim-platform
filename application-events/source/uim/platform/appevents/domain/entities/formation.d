/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.domain.entities.formation;

import uim.platform.service;
import uim.platform.appevents.domain.valueobjects;
import uim.platform.appevents.domain.enums.formation_status;
import vibe.data.json;
import std.conv : to;

@safe:

struct Formation {
    mixin TenantEntity!(FormationId);

    string name;
    string description;
    string globalAccountId;
    FormationStatus status;
    int systemCount = 0;

    Json toJson() const @safe {
        auto j = Json.emptyObject;
        j["id"]             = id.value;
        j["tenantId"]       = tenantId.value;
        j["name"]           = name;
        j["description"]    = description;
        j["globalAccountId"]= globalAccountId;
        j["status"]         = status.to!string;
        j["systemCount"]    = systemCount;
        return j;
    }
}
