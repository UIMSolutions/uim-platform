/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.domain.ports.repositories.triggers;

import uim.platform.process_automation.domain.types;
import uim.platform.process_automation.domain.entities.trigger;

interface TriggerRepository {
    Trigger findById(TriggerId id);
    Trigger[] findByTenant(TenantId tenantId);
    Trigger[] findByProcess(ProcessId processId);
    void save(Trigger t);
    void update(Trigger t);
    void remove(TriggerId id);
    long countByTenant(TenantId tenantId);
}
