/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.domain.ports.repositories.forms;

import uim.platform.process_automation.domain.types;
import uim.platform.process_automation.domain.entities.form;

interface FormRepository {
    Form findById(FormId id);
    Form[] findByTenant(TenantId tenantId);
    Form[] findByProject(ProjectId projectId);
    void save(Form f);
    void update(Form f);
    void remove(FormId id);
    size_t countByTenant(TenantId tenantId);
}
