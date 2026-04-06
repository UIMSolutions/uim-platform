/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.application.usecases.manage.manage_task_definitions;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

class ManageTaskDefinitionsUseCase : UIMUseCase {
    private TaskDefinitionRepository repo;

    this(TaskDefinitionRepository repo) {
        this.repo = repo;
    }

    TaskDefinition get_(string tenantId, string id) {
        return repo.findById(tenantId, id);
    }

    TaskDefinition[] list(string tenantId) {
        return repo.findByTenant(tenantId);
    }

    TaskDefinition[] listByProvider(string tenantId, string providerId) {
        return repo.findByProvider(tenantId, providerId);
    }

    TaskDefinition[] listByCategory(string tenantId, TaskCategory category) {
        return repo.findByCategory(tenantId, category);
    }

    CommandResult create(CreateTaskDefinitionRequest req) {
        TaskDefinition d;
        d.id = req.id;
        d.tenantId = req.tenantId;
        d.providerId = req.providerId;
        d.name = req.name;
        d.description = req.description;
        d.taskSchema = req.taskSchema;
        d.requiresClaim = req.requiresClaim;
        d.createdBy = req.createdBy;
        repo.save(req.tenantId, d);
        return CommandResult(true, req.id, "");
    }

    CommandResult update(UpdateTaskDefinitionRequest req) {
        auto existing = repo.findById(req.tenantId, req.id);
        if (existing == TaskDefinition.init)
            return CommandResult(false, "", "Task definition not found");
        if (req.name.length > 0) existing.name = req.name;
        if (req.description.length > 0) existing.description = req.description;
        if (req.taskSchema.length > 0) existing.taskSchema = req.taskSchema;
        existing.requiresClaim = req.requiresClaim;
        existing.modifiedBy = req.modifiedBy;
        repo.update(req.tenantId, existing);
        return CommandResult(true, req.id, "");
    }

    CommandResult activate(string tenantId, string id) {
        auto d = repo.findById(tenantId, id);
        if (d == TaskDefinition.init)
            return CommandResult(false, "", "Task definition not found");
        d.isActive = true;
        repo.update(tenantId, d);
        return CommandResult(true, id, "");
    }

    CommandResult deactivate(string tenantId, string id) {
        auto d = repo.findById(tenantId, id);
        if (d == TaskDefinition.init)
            return CommandResult(false, "", "Task definition not found");
        d.isActive = false;
        repo.update(tenantId, d);
        return CommandResult(true, id, "");
    }

    CommandResult remove(string tenantId, string id) {
        repo.remove(tenantId, id);
        return CommandResult(true, id, "");
    }
}
