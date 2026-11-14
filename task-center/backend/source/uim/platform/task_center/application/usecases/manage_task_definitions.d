/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.application.usecases.manage_task_definitions;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

class ManageTaskDefinitionsUseCase : IManageTaskDefinitions {
  protected ITaskDefinitionRepository definitions;
  protected ITaskProviderRepository providers;
  protected ITaskRepository tasks;

  this(ITaskDefinitionRepository definitions, ITaskProviderRepository providers, ITaskRepository tasks) {
    this.definitions = definitions;
    this.providers = providers;
    this.tasks = tasks;
  }

  TaskDefinition[] listTaskDefinitions(TenantId tenantId) {
    return definitions.findAll(tenantId);
  }

  TaskDefinition getTaskDefinition(TenantId tenantId, TaskDefinitionId id) {
    return definitions.findById(tenantId, id).required("Task definition '" ~ id.value ~ "'");
  }

  TaskDefinition createTaskDefinition(CreateTaskDefinitionRequest r) {
    TaskDefinition d;
    stampCreated!(TaskDefinition, TaskDefinitionId)(d, r.tenantId, r.actor, r.id);
    if (definitions.existsById(r.tenantId, d.id))
      throw TaskCenterException.conflict("Task definition '" ~ d.id.value ~ "' already exists");
    if (r.providerId.strip.length > 0)
      d.providerId = providers.findById(r.tenantId, TaskProviderId(r.providerId.strip))
        .required("Task provider '" ~ r.providerId ~ "'").id;
    d.name = r.name.strip;
    d.description = r.description;
    d.category = parseDomainEnumOr!TaskCategory(r.category, TaskCategory.approval, "category");
    d.defaultPriority = parseDomainEnumOr!TaskPriority(r.defaultPriority, TaskPriority.medium, "defaultPriority");
    d.allowedActions = r.allowedActions.dup;
    d.taskSchema = r.taskSchema;
    d.dueInDays = r.dueInDays;
    d.isActive = r.isActive;
    d.requiresClaim = r.requiresClaim;
    d.validate();
    ensureUniqueName(d);
    definitions.save(d);
    return d;
  }

  TaskDefinition updateTaskDefinition(UpdateTaskDefinitionRequest r) {
    auto d = getTaskDefinition(r.tenantId, r.id);
    r.name.applyTo(d.name);
    r.description.applyTo(d.description);
    applyEnum(r.category, d.category, "category");
    applyEnum(r.defaultPriority, d.defaultPriority, "defaultPriority");
    r.allowedActions.applyTo(d.allowedActions);
    r.taskSchema.applyTo(d.taskSchema);
    r.dueInDays.applyTo(d.dueInDays);
    r.isActive.applyTo(d.isActive);
    r.requiresClaim.applyTo(d.requiresClaim);
    d.name = d.name.strip;
    d.validate();
    ensureUniqueName(d);
    stampUpdated(d, r.actor);
    definitions.save(d);
    return d;
  }

  void deleteTaskDefinition(TenantId tenantId, TaskDefinitionId id) {
    auto d = getTaskDefinition(tenantId, id);
    auto open = tasks.findByDefinition(tenantId, id).count!(t => !t.isFinished);
    if (open > 0)
      throw TaskCenterException.ruleViolation("Task definition '" ~ d.name ~ "' is still used by " ~ countOf(open, "unfinished task"));
    definitions.removeById(tenantId, id);
  }

  protected void ensureUniqueName(const TaskDefinition d) {
    auto other = definitions.findByName(d.tenantId, d.name);
    if (!other.isNull && other.id != d.id)
      throw TaskCenterException.conflict("A task definition named '" ~ d.name ~ "' already exists");
  }
}
