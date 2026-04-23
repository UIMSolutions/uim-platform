/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.domain.ports.repositories.process_instances;

import uim.platform.process_automation.domain.types;
import uim.platform.process_automation.domain.entities.process_instance;

interface ProcessInstanceRepository : ITenantRepository!(ProcessInstance, ProcessInstanceId) {

    size_t countByProcess(ProcessId processId);
    ProcessInstance[] findByProcess(ProcessId processId);
    void removeByProcess(ProcessId processId);

    size_t countByStatus(TenantId tenantId, InstanceStatus status);
    ProcessInstance[] findByStatus(TenantId tenantId, InstanceStatus status);
    void removeByStatus(TenantId tenantId, InstanceStatus status);

}
