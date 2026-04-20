/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.domain.entities.service_account;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

struct ServiceAccount {
    mixin TenantEntity!(ServiceAccountId);

    string name;
    string description;
    ServiceAccountStatus status = ServiceAccountStatus.active;
    string clientId;
    string permissions;
    string lastUsedAt;
    string expiresAt;

    Json toJson() const {
        return entityToJson
            .set("name", name)
            .set("description", description)
            .set("status", status.to!string)
            .set("clientId", clientId)
            .set("permissions", permissions)
            .set("lastUsedAt", lastUsedAt)
            .set("expiresAt", expiresAt);
    }
}
