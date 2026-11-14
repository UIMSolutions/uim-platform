/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.application.usecases.manage_task_providers;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

class ManageTaskProvidersUseCase : IManageTaskProviders {
  protected ITaskProviderRepository providers;
  protected ITaskDefinitionRepository definitions;
  protected ITaskRepository tasks;

  this(ITaskProviderRepository providers, ITaskDefinitionRepository definitions, ITaskRepository tasks) {
    this.providers = providers;
    this.definitions = definitions;
    this.tasks = tasks;
  }

  TaskProvider[] listTaskProviders(TenantId tenantId) {
    return providers.findAll(tenantId);
  }

  TaskProvider getTaskProvider(TenantId tenantId, TaskProviderId id) {
    return providers.findById(tenantId, id).required("Task provider '" ~ id.value ~ "'");
  }

  TaskProvider createTaskProvider(CreateTaskProviderRequest r) {
    TaskProvider p;
    stampCreated!(TaskProvider, TaskProviderId)(p, r.tenantId, r.actor, r.id);
    if (providers.existsById(r.tenantId, p.id))
      throw TaskCenterException.conflict("Task provider '" ~ p.id.value ~ "' already exists");
    p.name = r.name.strip;
    p.description = r.description;
    p.providerType = parseDomainEnumOr!ProviderType(r.providerType, ProviderType.custom, "providerType");
    p.status = adminStatus(r.status.length > 0 ? r.status : "inactive");
    p.authType = parseDomainEnumOr!AuthenticationType(r.authType, AuthenticationType.none, "authType");
    p.endpointUrl = r.endpointUrl.strip;
    p.authEndpointUrl = r.authEndpointUrl.strip;
    p.clientId = r.clientId.strip;
    p.clientSecret = r.clientSecret;
    p.validate();
    ensureUniqueName(p);
    providers.save(p);
    return p;
  }

  TaskProvider updateTaskProvider(UpdateTaskProviderRequest r) {
    auto p = getTaskProvider(r.tenantId, r.id);
    r.name.applyTo(p.name);
    r.description.applyTo(p.description);
    applyEnum(r.providerType, p.providerType, "providerType");
    if (r.status.isSet)
      p.status = adminStatus(r.status.value);
    applyEnum(r.authType, p.authType, "authType");
    r.endpointUrl.applyTo(p.endpointUrl);
    r.authEndpointUrl.applyTo(p.authEndpointUrl);
    r.clientId.applyTo(p.clientId);
    r.clientSecret.applyTo(p.clientSecret);
    p.name = p.name.strip;
    p.validate();
    ensureUniqueName(p);
    stampUpdated(p, r.actor);
    providers.save(p);
    return p;
  }

  void deleteTaskProvider(TenantId tenantId, TaskProviderId id) {
    auto p = getTaskProvider(tenantId, id);
    if (auto n = definitions.findByProvider(tenantId, id).length)
      throw TaskCenterException.ruleViolation("Task provider '" ~ p.name ~ "' still offers " ~ countOf(n, "task definition"));
    if (auto n = tasks.findByProvider(tenantId, id).length)
      throw TaskCenterException.ruleViolation("Task provider '" ~ p.name ~ "' still has " ~ countOf(n, "task"));
    providers.removeById(tenantId, id);
  }

  protected void ensureUniqueName(const TaskProvider p) {
    auto other = providers.findByName(p.tenantId, p.name);
    if (!other.isNull && other.id != p.id)
      throw TaskCenterException.conflict("A task provider named '" ~ p.name ~ "' already exists");
  }
}

/// Administrators set active or inactive; syncing and error belong to the sync.
ProviderStatus adminStatus(string text) {
  auto s = parseDomainEnum!ProviderStatus(text, "status");
  if (s != ProviderStatus.active && s != ProviderStatus.inactive)
    throw TaskCenterException.invalid("status can only be set to 'active' or 'inactive'");
  return s;
}
