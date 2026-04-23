/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.domain.ports.repositories.actions;

import uim.platform.process_automation.domain.types;
import uim.platform.process_automation.domain.entities.action;

interface ActionRepository : ITenantRepository!(Action, ActionId) {

    size_t countByProject(ProjectId projectId);
    Action[] findByProject(ProjectId projectId);
    void removeByProject(ProjectId projectId);

}
