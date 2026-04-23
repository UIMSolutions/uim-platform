/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.infrastructure.persistence.memory.forms;

import uim.platform.process_automation;

mixin(ShowModule!());

@safe:
class MemoryFormRepository : FormRepository {
    private Form[] store;

    Form findById(FormId id) {
        foreach (f; store) {
            if (f.id == id)
                return f;
        }
        return Form.init;
    }

    Form[] findByTenant(TenantId tenantId) {
        return findAll().filter!(f => f.tenantId == tenantId).array;
    }

    Form[] findByProject(ProjectId projectId) {
        return findAll().filter!(f => f.projectId == projectId).array;
    }

    void save(Form f) {
        store ~= f;
    }

    void update(Form f) {
        foreach (existing; store) {
            if (existing.id == f.id) {
                existing = f;
                return;
            }
        }
    }

    void remove(FormId id) {
        store = findAll().filter!(f => f.id != id).array;
    }

    size_t countByTenant(TenantId tenantId) {
        return findAll().filter!(f => f.tenantId == tenantId).array.length;
    }
}
