/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.job_scheduling.domain.services.schedule_validator;

// import uim.platform.job_scheduling.domain.types;
import uim.platform.job_scheduling;

mixin(ShowModule!());

@safe:
struct ScheduleValidator {
    static bool isValidCron(string cron) {
        import std.array : split;

        auto parts = cron.split(" ");
        return parts.length == 5;
    }

    static bool isValidRepeatInterval(long intervalSeconds) {
        return intervalSeconds > 0;
    }

    static bool canActivate(ScheduleStatus current) {
        return current == ScheduleStatus.inactive;
    }

    static bool canDeactivate(ScheduleStatus current) {
        return current == ScheduleStatus.active;
    }
}
