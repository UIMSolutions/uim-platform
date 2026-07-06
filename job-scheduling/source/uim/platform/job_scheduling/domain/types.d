/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.job_scheduling.domain.types;

import uim.platform.job_scheduling;

mixin(ShowModule!());

@safe:

struct JobId {
    mixin(IdTemplate);
}
struct ScheduleId {
    mixin(IdTemplate);
}
struct RunLogId {
    mixin(IdTemplate);
}

struct ConfigurationId {
    mixin(IdTemplate);
}

