/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.application.usecases.manage.resource_groups;

import uim.platform.ai_launchpad.domain.ports.repositories.resource_groups;
import uim.platform.ai_launchpad.domain.entities.resource_group;
import uim.platform.ai_launchpad.domain.types;
import uim.platform.ai_launchpad.application.dto;

class ManageResourceGroupsUseCase : UIMUseCase {
  private IResourceGroupRepository repo;

  this(IResourceGroupRepository repo) {
    this.repo = repo;
  }

  CommandResult create(CreateResourceGroupRequest r) {
    if (r.resourceGroupId.length == 0) return CommandResult(false, "", "Resource group ID is required");

    ResourceGroup rg;
    rg.id = r.resourceGroupId;
    rg.connectionId = r.connectionId;
    rg.status = "active";

    foreach (ref lbl; r.labels) {
      if (lbl.length >= 2) {
        rg.labels ~= LabelPair(lbl[0], lbl[1]);
      }
    }

    rg.createdAt = "now";
    rg.modifiedAt = "now";
    repo.save(rg);
    return CommandResult(true, rg.id, "");
  }

  ResourceGroup get_(ResourceGroupId id, ConnectionId connectionId) {
    return repo.findById(id, connectionId);
  }

  ResourceGroup[] listByConnection(ConnectionId connectionId) {
    return repo.findByConnection(connectionId);
  }

  ResourceGroup[] listAll() {
    return repo.findAll();
  }

  CommandResult patch(PatchResourceGroupRequest r) {
    auto rg = repo.findById(r.resourceGroupId, r.connectionId);
    if (rg.id.length == 0) return CommandResult(false, "", "Resource group not found");

    if (r.labels.length > 0) {
      rg.labels = [];
      foreach (ref lbl; r.labels) {
        if (lbl.length >= 2) {
          rg.labels ~= LabelPair(lbl[0], lbl[1]);
        }
      }
    }

    rg.modifiedAt = "now";
    repo.save(rg);
    return CommandResult(true, rg.id, "");
  }

  CommandResult remove(ResourceGroupId id, ConnectionId connectionId) {
    auto rg = repo.findById(id, connectionId);
    if (rg.id.length == 0) return CommandResult(false, "", "Resource group not found");
    repo.remove(id, connectionId);
    return CommandResult(true, id, "");
  }
}
