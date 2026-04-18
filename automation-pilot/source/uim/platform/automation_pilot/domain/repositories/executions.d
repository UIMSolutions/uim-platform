/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.domain.repositories.executions;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

interface ExecutionRepository {
    bool existsById(ExecutionId id);
    Execution findById(ExecutionId id);

    Execution[] findAll();
    Execution[] findByTenant(TenantId tenantId);
    Execution[] findByCommand(CommandId commandId);
    Execution[] findByStatus(ExecutionStatus status);

    void save(Execution execution);
    void update(Execution execution);
    void remove(ExecutionId id);
}
