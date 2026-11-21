/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Resource group administration (AI API /admin/resourceGroups).
module uim.platform.ai_core.application.usecases.manage.resource_groups;

import uim.platform.ai_core;

mixin(ShowModule!());

@safe:

class ManageResourceGroupsUseCase : AiCoreInteractor, IManageResourceGroups {
  this(AiCoreRepositories repos, IClock clock, IAiCoreEventPublisher events, LifecyclePolicy policy) {
    super(repos, clock, events, policy);
  }

  ResourceGroup createResourceGroup(CreateResourceGroupRequest r) {
    auto id = r.id.strip;
    requireResourceGroupId(id);
    if (repos.resourceGroups.existsById(r.tenantId, ResourceGroupId(id)))
      throw AiCoreException.conflict("Resource group '" ~ id ~ "' already exists");
    auto g = buildResourceGroup(r.tenantId, r.actor, id, r.labels, now, policy);
    repos.resourceGroups.save(g);
    emit("resourceGroup.created", r.tenantId, id, Json(["status": Json(cast(string) g.status)]));
    return g;
  }

  ResourceGroup updateResourceGroup(UpdateResourceGroupRequest r) {
    auto g = getResourceGroup(r.tenantId, ResourceGroupId(r.id));
    if (r.labels.isSet)
      g.labels = checkedLabels(r.labels.value);
    stampUpdated(g, r.actor, now);
    repos.resourceGroups.save(g);
    return g;
  }

  ResourceGroup getResourceGroup(TenantId t, ResourceGroupId id) {
    return required(repos.resourceGroups.findById(t, id), "Resource group '" ~ id.value ~ "'");
  }

  ResourceGroup[] listResourceGroups(TenantId t) {
    return repos.resourceGroups.findAll(t);
  }

  size_t deleteResourceGroup(TenantId t, ResourceGroupId id) {
    getResourceGroup(t, id);
    auto activeRuns = repos.executions.findByGroup(t, id).count!(e => isActive(e.status));
    auto activeServing = repos.deployments.findByGroup(t, id).count!(d => isActive(d.status));
    if (activeRuns + activeServing > 0)
      throw AiCoreException.ruleViolation(format("Resource group '%s' has %d active execution(s) and %d active deployment(s); stop them first",
          id.value, activeRuns, activeServing));
    size_t removed;
    removed += repos.metrics.removeByGroup(t, id);
    removed += repos.schedules.removeByGroup(t, id);
    removed += repos.executions.removeByGroup(t, id);
    removed += repos.deployments.removeByGroup(t, id);
    removed += repos.configurations.removeByGroup(t, id);
    removed += repos.artifacts.removeByGroup(t, id);
    removed += repos.executables.removeByGroup(t, id);
    removed += repos.scenarios.removeByGroup(t, id);
    removed += repos.objectStoreSecrets.removeByGroup(t, id);
    repos.resourceGroups.removeById(t, id);
    emit("resourceGroup.deleted", t, id.value, Json(["removedResources": Json(removed)]));
    return removed;
  }

  ResourceGroup requireUsableGroup(TenantId t, ResourceGroupId id) {
    return groupOf(t, id);
  }
}
