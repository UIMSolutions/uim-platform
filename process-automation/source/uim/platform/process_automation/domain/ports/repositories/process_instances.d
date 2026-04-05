/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.domain.ports.repositories.process_instances;

import uim.platform.process_automation.domain.types;
import uim.platform.process_automation.domain.entities.process_instance;

interface ProcessInstanceRepository {
    ProcessInstance findById(ProcessInstanceId id);
    ProcessInstance[] findByTenant(TenantId tenantId);
    ProcessInstance[] findByProcess(ProcessId processId);
    ProcessInstance[] findByStatus(TenantId tenantId, InstanceStatus status);
    void save(ProcessInstance i);
    void update(ProcessInstance i);
    void remove(ProcessInstanceId id);
    long countByTenant(TenantId tenantId);
}
