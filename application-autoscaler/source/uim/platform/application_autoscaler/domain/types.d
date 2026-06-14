/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_autoscaler.domain.types;

import uim.platform.application_autoscaler;

// mixin(ShowModule!());

@safe:
// ---------------------------------------------------------------------------
// ID type aliases
// ---------------------------------------------------------------------------
struct ScalingPolicyId {
    mixin IdTemplate;

    string value;
    this(string value) {
        this.value = value;
    }
}
struct ScalingRuleId {
    mixin IdTemplate;

    string value;
    this(string value) {
        this.value = value;
    }
}
struct ScheduleId {
    mixin IdTemplate;

    string value;
    this(string value) {
        this.value = value;
    }
}
struct RecurringScheduleId {
    mixin IdTemplate;

    string value;
    this(string value) {
        this.value = value;
    }
}
struct SpecificDateScheduleId {
    mixin IdTemplate;

    string value;
    this(string value) {
        this.value = value;
    }
}
struct CustomMetricId {
    mixin IdTemplate;

    string value;
    this(string value) {
        this.value = value;
    }
}
struct ScalingHistoryId {
    mixin IdTemplate;

    string value;
    this(string value) {
        this.value = value;
    }
}
struct AppBindingId {
    mixin IdTemplate;

    string value;
    this(string value) {
        this.value = value;
    }
}

