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
        return Json.emptyObject
            .set("id",           id.value)
            .set("tenantId",     tenantId.value)
            .set("formationId",  formationId.value)
            .set("systemId",     systemId)
            .set("systemType",   systemType.to!string)
            .set("systemUrl",    systemUrl)
            .set("status",       status.to!string)
            .set("registeredAt", registeredAt)
            .set("createdAt",    createdAt)
            .set("createdBy",    createdBy.value);
    }
}
