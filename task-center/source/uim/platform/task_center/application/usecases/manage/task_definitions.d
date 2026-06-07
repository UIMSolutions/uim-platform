/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.application.usecases.manage.manage.task_definitions;

import uim.platform.task_center;

// mixin(ShowModule!());

@safe:

class ManageTaskDefinitionsUseCase { // TODO: UIMUseCase {
    private TaskDefinitionRepository repo;

    this(TaskDefinitionRepository repo) {
        this.repo = repo;
    }

    TaskDefinition getTaskDefinition(TenantId tenantId, TaskDefinitionId id) {
        return repo.findById(tenantId, id);
    }

    TaskDefinition[] listTaskDefinitions(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    TaskDefinition[] listTaskDefinitions(TenantId tenantId, string providerId) {
        return repo.findByProvider(tenantId, providerId);
    }

    TaskDefinition[] listTaskDefinitions(TenantId tenantId, TaskCategory category) {
        return repo.findByCategory(tenantId, category);
    }

    CommandResult createTaskDefinition(CreateTaskDefinitionRequest req) {
        TaskDefinition definition;
        definition.initEntity(req.tenantId);

        definition.id = req.id;
        definition.providerId = req.providerId;
        definition.name = req.name;
        definition.description = req.description;
        definition.taskSchema = req.taskSchema;
        definition.requiresClaim = req.requiresClaim;

        repo.save(definition);
        return CommandResult(true, req.id.value, "");
    }

    CommandResult updateTaskDefinition(UpdateTaskDefinitionRequest req) {
        auto existing = repo.findById(req.tenantId, req.id);
        if (existing.isNull)
            return CommandResult(false, "", "Task definition not found");
        
        if (req.name.length > 0)
            existing.name = req.name;
        if (req.description.length > 0)
            existing.description = req.description;
        if (req.taskSchema.length > 0)
            existing.taskSchema = req.taskSchema;
        existing.requiresClaim = req.requiresClaim;
        existing.updatedBy = req.updatedBy;

        repo.update(existing);
        return CommandResult(true, req.id.value, "");
    }

    CommandResult activateTaskDefinition(TenantId tenantId, TaskDefinitionId id) {
        auto definition = repo.findById(tenantId, id);
        if (definition.isNull)
            return CommandResult(false, "", "Task definition not found");
        
        definition.isActive = true;

        repo.update(definition);
        return CommandResult(true, id.value, "");
    }

    CommandResult deactivateTaskDefinition(TenantId tenantId, TaskDefinitionId id) {
        auto definition = repo.findById(tenantId, id);
        if (definition.isNull)
            return CommandResult(false, "", "Task definition not found");
        
        definition.isActive = false;

        repo.update(definition);
        return CommandResult(true, id.value, "");
    }

    CommandResult deleteTaskDefinition(TenantId tenantId, TaskDefinitionId id) {
        auto definition = repo.findById(tenantId, id);
        if (definition.isNull)
            return CommandResult(false, "", "Task definition not found");

        repo.remove(definition);
        return CommandResult(true, definition.id.value, "");
    }
}
