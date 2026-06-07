/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.print.domain.entities.print_client;

import uim.platform.print;

// mixin(ShowModule!());

@safe:

struct PrintClient {
    mixin TenantEntity!(PrintClientId);

    string name;
    string description;
    PrintClientStatus status = PrintClientStatus.registered;
    string version_;
    string hostName;
    string ipAddress;
    string osType;
    string osVersion;
    long lastSeenAt;
    string authToken;

    Json toJson() const {
        auto j = entityToJson
            .set("name", name)
            .set("description", description)
            .set("status", status.to!string)
            .set("version", version_)
            .set("hostName", hostName)
            .set("ipAddress", ipAddress)
            .set("osType", osType)
            .set("osVersion", osVersion)
            .set("lastSeenAt", lastSeenAt);
        return j;
    }
}
