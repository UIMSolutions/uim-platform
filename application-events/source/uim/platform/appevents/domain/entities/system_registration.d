/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.domain.entities.system_registration;

import uim.platform.service;
import uim.platform.appevents.domain.valueobjects;
import uim.platform.appevents.domain.enums.system_type;
import uim.platform.appevents.domain.enums.system_status;
import vibe.data.json;
import std.conv : to;

@safe:

struct SystemRegistration {
    mixin TenantEntity!(SystemRegistrationId);

    FormationId formationId;
    string systemId;
    SystemType systemType;
    string systemUrl;
    SystemStatus status;
    long registeredAt;

    Json toJson() const @safe {
        auto j = Json.emptyObject;
        j["id"]           = id.value;
        j["tenantId"]     = tenantId.value;
        j["formationId"]  = formationId.value;
        j["systemId"]     = systemId;
        j["systemType"]   = systemType.to!string;
        j["systemUrl"]    = systemUrl;
        j["status"]       = status.to!string;
        j["registeredAt"] = registeredAt;
        return j;
    }
}
