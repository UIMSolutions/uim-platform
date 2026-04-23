/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.domain.ports.repositories.processes;

import uim.platform.process_automation.domain.types;
import uim.platform.process_automation.domain.entities.process;

interface ProcessRepository : ITenantRepository!(Process, ProcessId) {

    size_t countByProject(ProjectId projectId);
    Process[] findByProject(ProjectId projectId);
    void removeByProject(ProjectId projectId);

    size_t countByCategory(TenantId tenantId, ProcessCategory category);
    Process[] findByCategory(TenantId tenantId, ProcessCategory category);
    void removeByCategory(TenantId tenantId, ProcessCategory category);

}
