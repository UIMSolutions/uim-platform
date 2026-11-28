/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Workspaces, connections to AI runtimes and resource groups.
///
/// A workspace can only be deleted when it has no connections and no prompt
/// collections; a connection only without resource groups and scenarios; a
/// resource group only while no execution or deployment is active in it.
/// New connections need an active workspace. Changing the URL, the auth URL
/// or the client credentials of a connection sets it back to "pending".
module uim.platform.ai_launchpad.application.usecases.runtimes;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

class ManageWorkspacesUseCase : ResourceInteractor!(Workspace, WorkspaceId, WorkspaceInput), IManageWorkspaces {
  this(AilpRepositories repos, IClock clock, IAuditTrail audit, IAilpUnitOfWork unitOfWork, AilpPolicy policy) {
    super(repos, clock, audit, unitOfWork, policy);
  }

  protected override IAilpRepository!(Workspace, WorkspaceId) store() {
    return repos.workspaces;
  }

  protected override string what() {
    return "Workspace";
  }

  protected override string eventPrefix() {
    return "workspace";
  }

  protected override WorkspaceInput toInput(const Workspace e) {
    return WorkspaceInput(e.name, e.description, cast(string) e.status);
  }

  protected override void fromInput(TenantId t, ref Workspace e, WorkspaceInput i, bool creating) {
    e.name = i.name.strip.length ? i.name.strip : e.id.value;
    e.description = i.description.strip;
    e.status = parseDomainEnumOr!WorkspaceStatus(i.status, WorkspaceStatus.active, "workspace status");
  }

  protected override void beforeRemove(TenantId t, const Workspace e, UserId actor) {
    auto w = e.id.value;
    requireUnused("Workspace '" ~ w ~ "'", repos.connections.countByReference(t, "workspaceId", w), "connections");
    requireUnused("Workspace '" ~ w ~ "'", repos.promptCollections.countByReference(t, "workspaceId", w),
      "prompt collections");
  }
}

class ManageConnectionsUseCase : ResourceInteractor!(Connection, ConnectionId, ConnectionInput), IManageConnections {
  protected IAiRuntime runtime;

  this(AilpRepositories repos, IClock clock, IAuditTrail audit, IAilpUnitOfWork unitOfWork, AilpPolicy policy, IAiRuntime runtime) {
    super(repos, clock, audit, unitOfWork, policy);
    this.runtime = runtime;
  }

  protected override IAilpRepository!(Connection, ConnectionId) store() {
    return repos.connections;
  }

  protected override string what() {
    return "Connection";
  }

  protected override string eventPrefix() {
    return "connection";
  }

  protected override string[] immutableAttributes() {
    return ["workspaceId"];
  }

  protected override ConnectionInput toInput(const Connection e) {
    ConnectionInput i;
    i.workspaceId = e.workspaceId.value;
    i.name = e.name;
    i.description = e.description;
    i.connectionType = cast(string) e.connectionType;
    i.url = e.url;
    i.authUrl = e.authUrl;
    i.clientId = e.clientId;
    i.clientSecret = ""; // write-only: "" keeps the stored secret
    i.defaultResourceGroup = e.defaultResourceGroup;
    return i;
  }

  protected override void fromInput(TenantId t, ref Connection e, ConnectionInput i, bool creating) {
    if (creating) {
      auto w = workspaceOf(t, i.workspaceId);
      w.requireActive("Creating a connection");
      e.workspaceId = w.id;
    }
    e.name = i.name.strip;
    e.description = i.description.strip;
    e.connectionType = parseDomainEnumOr!ConnectionType(i.connectionType, ConnectionType.aiCore, "connection type");
    e.url = i.url.strip.stripRight("/");
    e.authUrl = i.authUrl.strip;
    e.clientId = i.clientId.strip;
    if (i.clientSecret.length)
      e.clientSecret = i.clientSecret;
    e.defaultResourceGroup = i.defaultResourceGroup.strip;
  }

  protected override void beforeSave(TenantId t, ref Connection e, bool creating, const string[] changed) {
    if (creating) {
      e.invalidate("Created: validate the connection");
      return;
    }
    if (changed.canFind("url") || changed.canFind("authUrl") || changed.canFind("clientId") || changed.canFind("clientSecret")
      || changed.canFind("connectionType"))
      e.invalidate();
  }

  protected override void beforeRemove(TenantId t, const Connection e, UserId actor) {
    auto c = e.id.value;
    requireUnused("Connection '" ~ c ~ "'", repos.scenarios.countByReference(t, "connectionId", c), "scenarios");
    requireUnused("Connection '" ~ c ~ "'", repos.resourceGroups.countByReference(t, "connectionId", c), "resource groups");
  }

  Connection validateConnection(TenantId t, ConnectionId id, UserId actor) {
    auto c = get(t, id);
    workspaceOf(t, c.workspaceId.value).requireActive("Validating a connection");
    auto check = runtime.validateConnection(c);
    c.status = check.ok ? ConnectionStatus.active : ConnectionStatus.error;
    c.statusMessage = check.message;
    c.lastValidatedAt = now;
    stampUpdated(c, actor, now);
    repos.connections.save(c);
    emit(check.ok ? "connection.validated" : "connection.invalid", t, actor, id.value, Json([
        "message": Json(check.message)
      ]));
    return c;
  }
}

class ManageResourceGroupsUseCase : ResourceInteractor!(ResourceGroup, ResourceGroupId, ResourceGroupInput), IManageResourceGroups {
  this(AilpRepositories repos, IClock clock, IAuditTrail audit, IAilpUnitOfWork unitOfWork, AilpPolicy policy) {
    super(repos, clock, audit, unitOfWork, policy);
  }

  protected override IAilpRepository!(ResourceGroup, ResourceGroupId) store() {
    return repos.resourceGroups;
  }

  protected override string what() {
    return "Resource group";
  }

  protected override string eventPrefix() {
    return "resourceGroup";
  }

  protected override string[] immutableAttributes() {
    return ["connectionId"];
  }

  protected override ResourceGroupInput toInput(const ResourceGroup e) {
    return ResourceGroupInput(e.connectionId.value, e.description, e.labels.dup, cast(string) e.status);
  }

  protected override void fromInput(TenantId t, ref ResourceGroup e, ResourceGroupInput i, bool creating) {
    if (creating)
      e.connectionId = connectionOf(t, i.connectionId).id;
    e.description = i.description.strip;
    e.labels = i.labels.map!(l => l.strip).filter!(l => l.length > 0).array;
    e.status = parseDomainEnumOr!ResourceGroupStatus(i.status, ResourceGroupStatus.ready, "resource group status");
  }

  protected override void beforeSave(TenantId t, ref ResourceGroup e, bool creating, const string[] changed) {
    if (!creating && !e.isReady)
      requireUnused("Resource group '" ~ e.id.value ~ "'", activeWorkloads(t, e.id.value), "active executions or deployments");
  }

  protected override void beforeRemove(TenantId t, const ResourceGroup e, UserId actor) {
    requireUnused("Resource group '" ~ e.id.value ~ "'", activeWorkloads(t, e.id.value), "active executions or deployments");
  }

  protected long activeWorkloads(TenantId t, string group) {
    return repos.executions.findByReference(t, "resourceGroupId", group).count!(x => x.isActive)
      + repos.deployments.findByReference(t, "resourceGroupId", group).count!(x => x.isActive);
  }
}
