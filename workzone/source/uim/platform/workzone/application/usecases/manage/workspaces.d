/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.application.usecases.manage.workspaces;

// import std.uuid;
// import std.datetime.systime : Clock;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.workspace;
import uim.platform.workzone.domain.ports.repositories.workspaces;
import uim.platform.workzone.application.dto;

class ManageWorkspacesUseCase : UIMUseCase {
  private WorkspaceRepository repo;

  this(WorkspaceRepository repo) {
    this.repo = repo;
  }

  CommandResult createWorkspace(CreateWorkspaceRequest req) {
    if (req.name.length == 0)
      return CommandResult(false, "", "Workspace name is required");

    auto now = Clock.currStdTime();
    auto ws = Workspace();
    ws.id = randomUUID();
    ws.tenantId = req.tenantId;
    ws.name = req.name;
    ws.description = req.description;
    ws.alias_ = req.alias_;
    ws.type = req.type;
    ws.status = WorkspaceStatus.active;
    ws.settings = req.settings;
    ws.createdAt = now;
    ws.updatedAt = now;
    ws.createdBy = req.createdBy;

    // Creator becomes owner
    if (req.createdBy.length > 0) {
      ws.members = [WorkspaceMember(req.createdBy, "", MemberRole.owner, now)];
    }

    repo.save(ws);
    return CommandResult(ws.id, "");
  }

  Workspace* getWorkspace(WorkspaceId tenantId, id tenantId) {
    return repo.findById(tenantId, id);
  }

  Workspace[] listWorkspaces(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  Workspace[] listByMember(UserId usertenantId, id tenantId) {
    return repo.findByMember(usertenantId, id);
  }

  CommandResult updateWorkspace(UpdateWorkspaceRequest req) {
    auto ws = repo.findById(req.id, req.tenantId);
    if (ws is null)
      return CommandResult(false, "", "Workspace not found");

    if (req.name.length > 0)
      ws.name = req.name;
    if (req.description.length > 0)
      ws.description = req.description;
    if (req.imageUrl.length > 0)
      ws.imageUrl = req.imageUrl;
    ws.settings = req.settings;
    ws.updatedAt = Clock.currStdTime();

    repo.update(*ws);
    return CommandResult(ws.id, "");
  }

  CommandResult addMember(AddMemberRequest req) {
    auto ws = repo.findById(req.workspaceId, req.tenantId);
    if (ws is null)
      return CommandResult(false, "", "Workspace not found");

    // Check duplicate
    foreach (ref m; ws.members)
      if (m.userId == req.userId)
        return CommandResult(false, "", "User is already a member");

    ws.members ~= WorkspaceMember(req.userId, req.displayName, req.role, Clock.currStdTime());
    ws.updatedAt = Clock.currStdTime();
    repo.update(*ws);
    return CommandResult(ws.id, "");
  }

  CommandResult removeMember(WorkspaceId wstenantId, id tenantId, UserId userId) {
    auto ws = repo.findById(wstenantId, id);
    if (ws is null)
      return CommandResult(false, "", "Workspace not found");

    // import std.algorithm : remove;
    size_t idx = size_t.max;
    foreach (i, ref m; ws.members)
      if (m.userId == userId) {
        idx = i;
        break;
      }
    if (idx == size_t.max)
      return CommandResult(false, "", "Member not found");

    ws.members = ws.members.remove(idx);
    ws.updatedAt = Clock.currStdTime();
    repo.update(*ws);
    return CommandResult(ws.id, "");
  }

  CommandResult archiveWorkspace(WorkspaceId tenantId, id tenantId) {
    auto ws = repo.findById(tenantId, id);
    if (ws is null)
      return CommandResult(false, "", "Workspace not found");
    ws.status = WorkspaceStatus.archived;
    ws.updatedAt = Clock.currStdTime();
    repo.update(*ws);
    return CommandResult(ws.id, "");
  }

  void deleteWorkspace(WorkspaceId tenantId, id tenantId) {
    repo.remove(tenantId, id);
  }
}
