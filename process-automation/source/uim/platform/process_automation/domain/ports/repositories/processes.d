/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.domain.ports.repositories.processes;

import uim.platform.process_automation.domain.types;
import uim.platform.process_automation.domain.entities.process;

interface ProcessRepository {
    Process findById(ProcessId id);
    Process[] findByTenant(TenantId tenantId);
    Process[] findByProject(ProjectId projectId);
    Process[] findByCategory(TenantId tenantId, ProcessCategory category);
    void save(Process p);
    void update(Process p);
    void remove(ProcessId id);
    long countByTenant(TenantId tenantId);
}
