/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.customer_identity.domain.types;

import uim.platform.customer_identity;

// mixin(ShowModule!());

@safe:

struct CustomerId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}

struct CustomerSessionId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}

struct SocialIdentityId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}

struct ConsentRecordId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}

struct AuditLogId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}

struct IdentityProviderId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}

struct ScreenSetId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}

struct SitePolicyId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
