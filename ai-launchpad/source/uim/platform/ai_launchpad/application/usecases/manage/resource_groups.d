/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.application.usecases.manage.resource_groups;
// import uim.platform.ai_launchpad.domain.ports.repositories.resource_groups;
// import uim.platform.ai_launchpad.domain.entities.resource_group;
// import uim.platform.ai_launchpad.domain.types;
// import uim.platform.ai_launchpad.application.dto;
import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:
class ManageResourceGroupsUseCase { // TODO: UIMUseCase {
  private IResourceGroupRepository repo;

  this(IResourceGroupRepository repo) {
    this.repo = repo;
  }

  CommandResult createResourceGroup(CreateResourceGroupRequest r) {
    if (r.resourceGroupId.isEmpty)
      return CommandResult(false, "", "Resource group ID is required");

    ResourceGroup rg;
    rg.initEntity(r.tenantId);
    
    rg.id = r.resourceGroupId;
    rg.connectionId = r.connectionId;
    rg.status = "active";

    foreach (lbl; r.labels) {
      if (lbl.length >= 2) {
        rg.labels ~= LabelPair(lbl[0], lbl[1]);
      }
    }

    repo.save(rg);
    return CommandResult(true, rg.id.value, "");
  }

  ResourceGroup getResourceGroup(TenantId tenantId, ConnectionId connectionId, ResourceGroupId id) {
    return repo.findById(tenantId, connectionId, id);
  }

  ResourceGroup[] listResourceGroups(TenantId tenantId, ConnectionId connectionId) {
    return repo.findByConnection(tenantId, connectionId);
  }

  ResourceGroup[] listResourceGroups() {
    return repo.findAll();
  }

  CommandResult patchResourceGroup(PatchResourceGroupRequest r) {
    auto rg = repo.findById(r.tenantId, r.connectionId, r.resourceGroupId);
    if (rg.isNull)
      return CommandResult(false, "", "Resource group not found");

    if (r.labels.length > 0) {
      rg.labels = [];
      foreach (lbl; r.labels) {
        if (lbl.length >= 2) {
          rg.labels ~= LabelPair(lbl[0], lbl[1]);
        }
      }
    }

    rg.updatedAt = "now";
    repo.save(rg);
    return CommandResult(true, rg.id.value, "");
  }

  CommandResult deleteResourceGroup(TenantId tenantId, ConnectionId connectionId, ResourceGroupId id) {
    auto entity = repo.findById(tenantId, connectionId, id);
    if (entity.isNull)
      return CommandResult(false, "", "Resource group not found");

    repo.remove(entity);
    return CommandResult(true, entity.id.value, "");
  }
}
