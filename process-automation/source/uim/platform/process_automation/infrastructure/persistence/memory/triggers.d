/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.infrastructure.persistence.memory.triggers;

import uim.platform.process_automation;

mixin(ShowModule!());

@safe:
class MemoryTriggerRepository : TenantRepository!(Trigger, TriggerId), TriggerRepository {

    size_t countByProcess(ProcessId processId) {
        return findByProcess(processId).length;
    }
    Trigger[] findByProcess(ProcessId processId) {
        return findAll().filter!(t => t.processId == processId).array;
    }
    void removeByProcess(ProcessId processId) {
        findByProcess(processId).each!(t => remove(t));
    }

}
