/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.domain.ports.repositories.automations;
// import uim.platform.process_automation.domain.types;
// import uim.platform.process_automation.domain.entities.automation;
import uim.platform.process_automation;

mixin(ShowModule!());

@safe:
interface AutomationRepository : ITenantRepository!(Automation, AutomationId) {

    size_t countByProject(TenantId tenantId, ProjectId projectId);
    Automation[] findByProject(TenantId tenantId, ProjectId projectId);
    void removeByProject(TenantId tenantId, ProjectId projectId);

}
