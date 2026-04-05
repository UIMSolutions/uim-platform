/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.job_scheduling.domain.services.run_tracker;

import uim.platform.job_scheduling.domain.types;

struct RunTracker {
    static bool canTransition(RunStatus from, RunStatus to) {
        if (to == RunStatus.triggered)
            return from == RunStatus.scheduled;
        if (to == RunStatus.running)
            return from == RunStatus.triggered;
        if (to == RunStatus.completed)
            return from == RunStatus.running;
        if (to == RunStatus.failed)
            return from == RunStatus.running;
        if (to == RunStatus.deadLettered)
            return from == RunStatus.failed;
        return false;
    }

    static bool isTerminal(RunStatus status) {
        return status == RunStatus.completed
            || status == RunStatus.failed
            || status == RunStatus.deadLettered;
    }
}
