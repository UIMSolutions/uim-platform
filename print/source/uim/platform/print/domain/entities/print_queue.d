/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.print.domain.entities.print_queue;

import uim.platform.print;
mixin(ShowModule!());

@safe:

struct PrintQueue {
    mixin TenantEntity!(PrintQueueId);

    string name;
    string description;
    PrintQueueStatus status = PrintQueueStatus.active;
    PrinterId printerId;
    string location;
    string costCenter;
    bool isDefault;
    int maxRetries = 3;
    int retentionDays = 7;

    Json toJson() const {
        auto j = entityToJson
            .set("name", name)
            .set("description", description)
            .set("status", status.to!string)
            .set("printerId", printerId.value)
            .set("location", location)
            .set("costCenter", costCenter)
            .set("isDefault", isDefault)
            .set("maxRetries", maxRetries)
            .set("retentionDays", retentionDays);
        return j;
    }
}
