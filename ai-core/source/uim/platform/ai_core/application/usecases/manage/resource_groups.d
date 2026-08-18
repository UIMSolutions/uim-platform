/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.application.usecases.manage.resource_groups;
// import uim.platform.ai_core.domain.types;
// import uim.platform.ai_core.domain.entities.resource_group;
// import uim.platform.ai_core.domain.ports.repositories.resource_groups;

import uim.platform.ai_core;

mixin(ShowModule!());

@safe:
class ManageResourceGroupsUseCase {
  protected IResourceGroupRepository repo;

  this(IResourceGroupRepository repo) {
    this.repo = repo;
  }

  UsecaseResult createResourceGroup(CreateResourceGroupRequest r) {
    if (r.resourceGroupId.isEmpty)
      return UsecaseResult(false, "", "Resource group ID is required");
    if (r.tenantId.isEmpty)
      return UsecaseResult(false, "", "Tenant ID is required");

    if (repo.existsById(r.tenantId, r.resourceGroupId))
      return UsecaseResult(false, "", "Resource group already exists");

    auto rg = ResourceGroup(r.tenantId);
    rg.id = r.resourceGroupId;
    rg.status = "active";

    // Parse labels
    ResourceGroupLabel[] labels;
    foreach (pair; r.labels) {
      if (pair.length >= 2) {
        ResourceGroupLabel lbl;
        lbl.key = pair[0];
        lbl.value = pair[1];
        labels ~= lbl;
      }
    }
    rg.labels = labels;
    rg.createdAt = currentTimestamp;

    repo.save(rg);
    return UsecaseResult(true, rg.id.value, "");
  }

  UsecaseResult patchResourceGroup(PatchResourceGroupRequest r) {
    auto rg = repo.findById(r.tenantId, r.resourceGroupId);
    if (rg.isNull)
      return UsecaseResult(false, "", "Resource group not found");

    ResourceGroupLabel[] labels;
    foreach (pair; r.labels.filter!(p => p.length >= 2)) {
      ResourceGroupLabel lbl;
      lbl.key = pair[0];
      lbl.value = pair[1];
      labels ~= lbl;
    }
    rg.labels = labels;

    repo.update(rg);
    return UsecaseResult(true, rg.id.value, "");
  }

  ResourceGroup getResourceGroup(TenantId tenantId, ResourceGroupId resourceGroupId) {
    return repo.findById(tenantId, resourceGroupId);
  }

  ResourceGroup[] listResourceGroups(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  size_t count(TenantId tenantId) {
    return repo.countByTenant(tenantId);
  }

  UsecaseResult deleteResourceGroup(TenantId tenantId, ResourceGroupId resourceGroupId) {
    auto group = repo.findById(tenantId, resourceGroupId);
    if (group.isNull)
      return UsecaseResult(false, "", "Resource group not found");

    repo.remove(group);
    return UsecaseResult(true, group.id.value, "");
  }

}

///
unittest {
//    auto repo = new ResourceGroupRepository();
//    auto usecase = new ManageResourceGroupsUseCase(repo);
//    auto tenantId = TenantId("test-tenant");
//
//    // Test list
//    auto items = usecase.listResourceGroups(tenantId);
//    assert(items !is null);

}
