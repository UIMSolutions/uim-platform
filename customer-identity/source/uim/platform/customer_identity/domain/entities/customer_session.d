/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.customer_identity.domain.entities.customer_session;

import uim.platform.customer_identity;

mixin(ShowModule!());

@safe:

struct CustomerSession {
    mixin TenantEntity!(CustomerSessionId);

    CustomerId customerId;
    string token;
    string deviceInfo;
    string ipAddress;
    string userAgent;
    long expiresAt;
    SessionStatus status = SessionStatus.active;

    Json toJson() const {
        return entityToJson
            .set("customerId", customerId.value)
            .set("token", token)
            .set("deviceInfo", deviceInfo)
            .set("ipAddress", ipAddress)
            .set("userAgent", userAgent)
            .set("expiresAt", expiresAt)
            .set("status", status.to!string);
    }
}
