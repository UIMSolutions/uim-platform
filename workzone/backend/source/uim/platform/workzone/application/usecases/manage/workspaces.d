/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.application.usecases.manage.workspaces;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// Interactor: workspaces. The creator becomes owner; names and aliases are
/// unique per tenant; deletion cascades to everything inside the workspace.
class ManageWorkspacesUseCase
  : ResourceUseCase!(Workspace, WorkspaceId, CreateWorkspaceRequest, UpdateWorkspaceRequest),
  IManageWorkspacesUseCase {

  protected CascadeDeleter cascade;
  protected FeedRecorder feed;

  this(WorkzoneRepositories repos, CascadeDeleter cascade, FeedRecorder feed, IWorkzoneEventPublisher publisher) {
    super(repos, repos.workspaces, publisher, "Workspace", "workzone.workspace");
    this.cascade = cascade;
    this.feed = feed;
  }

  override protected Workspace build(CreateWorkspaceRequest r) {
    auto ws = Workspace(r.tenantId);
    assignMatching(ws, r.spec);
    check(ws);
    normalizeMembers(ws, r.actor.value, ws.createdAt);
    return ws;
  }

  override protected void apply(ref Workspace ws, WorkspaceSpec spec) {
    ensureState(ws.status != WorkspaceStatus.archived, "Workspace '" ~ ws.name ~ "' is archived — restore it first");
    assignMatching(ws, spec);
    normalizeMembers(ws, "", nowStdTime());
    check(ws);
  }

  protected void check(ref Workspace ws) {
    ws.name = ws.name.strip;
    validateDisplayName("Workspace name", ws.name, 80);
    ensureUnique(repos.workspaces.findByName(ws.tenantId, ws.name), ws);
    ws.alias_ = ws.alias_.strip.length ? ws.alias_.strip : toSlug(ws.name);
    validateSlug("Workspace alias", ws.alias_);
    auto alias_ = ws.alias_;
    auto id = ws.id;
    ensureState(repos.workspaces.findMatching(ws.tenantId, (const Workspace o) => o.id != id && o.alias_ == alias_).length == 0,
      "Workspace alias '" ~ ws.alias_ ~ "' is already used");
    validateOptionalUrl("Image URL", ws.imageUrl);
    if (ws.type == WorkspaceType.external)
      ws.allowExternalMembers = true;
  }

  override protected void afterRemove(Workspace ws) {
    cascade.clearWorkspace(ws.tenantId, ws.id);
  }

  UsecaseResult addMember(TenantId tenantId, WorkspaceId id, WorkspaceMember member, UserId actor) {
    auto result = transition(tenantId, id, actor, "member added", (ref Workspace ws) {
      ensureAcceptsContent(ws, "members");
      admitMember(ws, member, nowStdTime());
    });
    if (result.isSuccess)
      feed.record(tenantId, id, UserId(member.userId), "joined", "workspace", id.value, "");
    return result;
  }

  UsecaseResult removeMember(TenantId tenantId, WorkspaceId id, string userId, UserId actor) {
    return transition(tenantId, id, actor, "member removed", (ref Workspace ws) {
      dismissMember(ws, userId);
    });
  }

  UsecaseResult changeRole(TenantId tenantId, WorkspaceId id, string userId, MemberRole role, UserId actor) {
    return transition(tenantId, id, actor, "role changed", (ref Workspace ws) {
      assignMemberRole(ws, userId, role);
    });
  }

  UsecaseResult archive(TenantId tenantId, WorkspaceId id, UserId actor) {
    return transition(tenantId, id, actor, "archived", (ref Workspace ws) {
      ensureState(ws.status != WorkspaceStatus.archived, "Workspace '" ~ ws.name ~ "' is already archived");
      ws.status = WorkspaceStatus.archived;
    });
  }

  UsecaseResult suspend(TenantId tenantId, WorkspaceId id, UserId actor) {
    return transition(tenantId, id, actor, "suspended", (ref Workspace ws) {
      ensureState(ws.status == WorkspaceStatus.active, "Only active workspaces can be suspended");
      ws.status = WorkspaceStatus.suspended;
    });
  }

  UsecaseResult restore(TenantId tenantId, WorkspaceId id, UserId actor) {
    return transition(tenantId, id, actor, "restored", (ref Workspace ws) {
      ensureState(ws.status != WorkspaceStatus.active, "Workspace '" ~ ws.name ~ "' is already active");
      ws.status = WorkspaceStatus.active;
    });
  }
}
