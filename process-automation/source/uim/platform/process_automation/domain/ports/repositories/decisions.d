/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.domain.ports.repositories.decisions;

import uim.platform.process_automation.domain.types;
import uim.platform.process_automation.domain.entities.decision;

interface DecisionRepository {
    Decision findById(DecisionId id);
    Decision[] findByTenant(TenantId tenantId);
    Decision[] findByProject(ProjectId projectId);
    void save(Decision d);
    void update(Decision d);
    void remove(DecisionId id);
    long countByTenant(TenantId tenantId);
}
