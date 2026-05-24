/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.saas_provisioning.domain.types;

import uim.platform.saas_provisioning;

mixin(ShowModule!());

@safe:

// ---------------------------------------------------------------------------
// Domain ID value types
// ---------------------------------------------------------------------------

struct SaasApplicationId {
    mixin DomainId;

    this(string value) {
        this.value = value;
    }

    string value;
}

struct AppSubscriptionId {
    mixin DomainId;

    this(string value) {
        this.value = value;
    }

    string value;
}

struct SubscriptionJobId {
    mixin DomainId;

    this(string value) {
        this.value = value;
    }

    string value;
}
