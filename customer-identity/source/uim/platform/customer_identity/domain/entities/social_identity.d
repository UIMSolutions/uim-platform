/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.customer_identity.domain.entities.social_identity;

import uim.platform.customer_identity;

// mixin(ShowModule!());

@safe:

struct SocialIdentity {
    mixin TenantEntity!(SocialIdentityId);

    CustomerId customerId;
    LoginProvider provider;
    string providerUserId;
    string providerEmail;
    string displayName;
    string accessToken;
    string refreshToken;
    long tokenExpiresAt;
    string profileData;
    SocialIdentityStatus status = SocialIdentityStatus.linked;

    Json toJson() const {
        return entityToJson
            .set("customerId", customerId.value)
            .set("provider", provider.to!string)
            .set("providerUserId", providerUserId)
            .set("providerEmail", providerEmail)
            .set("displayName", displayName)
            .set("tokenExpiresAt", tokenExpiresAt)
            .set("profileData", profileData)
            .set("status", status.to!string);
    }
}
