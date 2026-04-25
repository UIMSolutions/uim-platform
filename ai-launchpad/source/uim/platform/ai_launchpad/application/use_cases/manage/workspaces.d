/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.application.usecases.manage.workspaces;

import uim.platform.ai_launchpad.domain.ports.repositories.workspaces;
import uim.platform.ai_launchpad.domain.entities.workspace : Workspace;
import uim.platform.ai_launchpad.domain.types;
import uim.platform.ai_launchpad.application.dto;

import std.uuid : randomUUID;
import std.conv : to;

class ManageWorkspacesUseCase { // TODO: UIMUseCase {
  private IWorkspaceRepository repo;

  this(IWorkspaceRepository repo) {
    this.repo = repo;
  }

  CommandResult create(CreateWorkspaceRequest r) {
    if (r.name.length == 0)
      return CommandResult(false, "", "Workspace name is required");

    Workspace w;
    w.id = randomUUID();
    w.name = r.name;
    w.description = r.description;
    w.tenantId = r.tenantId;
    w.status = WorkspaceStatus.active;
    w.connectionCount = 0;
    w.createdAt = "now";
    w.updatedAt = "now";
    repo.save(w);
    return CommandResult(true, w.id, "");
  }

  Workspace getById(WorkspaceId id) {
    return repo.findById(id);
  }

  Workspace[] listByTenant(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  Workspace[] listAll() {
    return repo.findAll();
  }

  CommandResult patch(PatchWorkspaceRequest r) {
    auto w = repo.findById(r.workspaceId);
    if (w.id.isEmpty)
      return CommandResult(false, "", "Workspace not found");
    if (r.name.length > 0)
      w.name = r.name;
    if (r.description.length > 0)
      w.description = r.description;
    w.updatedAt = "now";
    repo.save(w);
    return CommandResult(true, w.id, "");
  }

  CommandResult remove(WorkspaceId id) {
    auto w = repo.findById(id);
    if (w.id.isEmpty)
      return CommandResult(false, "", "Workspace not found");
    repo.remove(id);
    return CommandResult(true, id.toString, "");
  }
}
