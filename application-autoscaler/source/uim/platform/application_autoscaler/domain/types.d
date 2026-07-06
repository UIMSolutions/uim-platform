/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_autoscaler.domain.types;

import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:
// ---------------------------------------------------------------------------
// ID type aliases
// ---------------------------------------------------------------------------
struct ScalingPolicyId {
    mixin(IdTemplate);
}
struct ScalingRuleId {
    mixin(IdTemplate);
}
struct ScheduleId {
    mixin(IdTemplate);
}
struct RecurringScheduleId {
    mixin(IdTemplate);
}
struct SpecificDateScheduleId {
    mixin(IdTemplate);
}
struct CustomMetricId {
    mixin(IdTemplate);
}
struct ScalingHistoryId {
    mixin(IdTemplate);
}
struct AppBindingId {
    mixin(IdTemplate);
}

