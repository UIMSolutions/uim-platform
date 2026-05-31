/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.alert_notification.domain.types;

import uim.platform.alert_notification;

mixin(ShowModule!());

@safe:

// ---------------------------------------------------------------------------
// Domain ID value types
// ---------------------------------------------------------------------------

struct ConditionId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}

struct ActionId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}

struct SubscriptionId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}

struct AlertEventId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}

struct MatchedEventId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}

struct UndeliveredEventId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
