/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.customer_identity.domain.types;

import uim.platform.customer_identity;

mixin(ShowModule!());

@safe:

struct CustomerId {
    mixin(IdTemplate);
}

struct CustomerSessionId {
    mixin(IdTemplate);
}

struct SocialIdentityId {
    mixin(IdTemplate);
}

struct ConsentRecordId {
    mixin(IdTemplate);
}

struct AuditLogId {
    mixin(IdTemplate);
}

struct IdentityProviderId {
    mixin(IdTemplate);
}

struct ScreenSetId {
    mixin(IdTemplate);
}

struct SitePolicyId {
    mixin(IdTemplate);
}
