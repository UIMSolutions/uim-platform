/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.presentation.http.workspace;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
import uim.platform.workzone.application.usecases.manage.workspaces;
import uim.platform.workzone.application.dto;
import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.workspace;
import uim.platform.identity_authentication.presentation.http.json_utils;

class WorkspaceController : PlatformController {
  private ManageWorkspacesUseCase useCase;

  this(ManageWorkspacesUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/workspaces", &handleCreate);
    router.get("/api/v1/workspaces", &handleList);
    router.get("/api/v1/workspaces/*", &handleGet);
    router.put("/api/v1/workspaces/*", &handleUpdate);
    router.delete_("/api/v1/workspaces/*", &handleDelete);
    router.post("/api/v1/workspaces/members", &handleAddMember);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = CreateWorkspaceRequest();
      r.tenantId = req.getTenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.alias_ = j.getString("alias");
      r.createdBy = j.getString("createdBy");

      auto typeStr = j.getString("type");
      if (typeStr == "project")
        r.type = WorkspaceType.project;
      else if (typeStr == "department")
        r.type = WorkspaceType.department;
      else if (typeStr == "public")
        r.type = WorkspaceType.public_;
      else if (typeStr == "external")
        r.type = WorkspaceType.external;
      else
        r.type = WorkspaceType.team;

      r.settings = parseWorkspaceSettings(j);

      auto result = useCase.createWorkspace(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Workspace created successfully");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto workspaces = useCase.listWorkspaces(tenantId);
      auto arr = Json.emptyArray;
      foreach (w; workspaces)
        arr ~= serializeWorkspace(w);
      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", workspaces.length)
        .set("message", "Workspaces retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      // Check for sub-resources
      if (id == "members") {
        handleAddMember(req, res);
        return;
      }

      TenantId tenantId = req.getTenantId;
      auto ws = useCase.getWorkspace(tenantId, id);
      if (ws.isNull) {
        writeError(res, 404, "Workspace not found");
        return;
      }
      res.writeJsonBody(serializeWorkspace(*ws), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = UpdateWorkspaceRequest();
      r.id = extractIdFromPath(req.requestURI);
      r.tenantId = req.getTenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.imageUrl = j.getString("imageUrl");
      r.settings = parseWorkspaceSettings(j);

      auto result = useCase.updateWorkspace(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("status", "updated")
          .set("message", "Workspace updated successfully");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      useCase.deleteWorkspace(tenantId, id);
      res.writeBody("", 204);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleAddMember(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = AddMemberRequest();
      r.workspaceId = j.getString("workspaceId");
      r.tenantId = req.getTenantId;
      r.userId = j.getString("userId");
      r.displayName = j.getString("displayName");

      auto roleStr = j.getString("role");
      if (roleStr == "admin")
        r.role = MemberRole.admin;
      else if (roleStr == "owner")
        r.role = MemberRole.owner;
      else if (roleStr == "viewer")
        r.role = MemberRole.viewer;
      else
        r.role = MemberRole.contributor;

      auto result = useCase.addMember(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("status", "member_added")
          .set("message", "Member added successfully");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}

private WorkspaceSettings parseWorkspaceSettings(Json j) {
  WorkspaceSettings s;
  auto sv = "settings" in j;
  if (sv !is null && (*sv).isObject) {
    auto sj = *sv;
    s.allowExternalMembers = getBoolean(sj, "allowExternalMembers");
    s.enableNotifications = getBoolean(sj, "enableNotifications", true);
    s.enableFeeds = getBoolean(sj, "enableFeeds", true);
    s.enableWiki = getBoolean(sj, "enableWiki", true);
    s.enableKnowledgeBase = getBoolean(sj, "enableKnowledgeBase", true);
    s.enableForum = getBoolean(sj, "enableForum");
    s.defaultLanguage = getString(sj, "defaultLanguage");
  }
  return s;
}

private Json serializeWorkspace(Workspace w) {
  // import std.conv : to;

  auto j = Json.emptyObject
    .set("id", w.id)
    .set("tenantId", w.tenantId)
    .set("name", w.name)
    .set("description", w.description)
    .set("alias", w.alias_)
    .set("type", w.type.to!string)
    .set("status", w.status.to!string)
    .set("imageUrl", w.imageUrl)
    .set("createdAt", w.createdAt)
    .set("updatedAt", w.updatedAt)
    .set("createdBy", w.createdBy);

  // Members
  auto members = Json.emptyArray;
  foreach (m; w.members) {
    members ~= Json.emptyObject
      .set("userId", m.userId)
      .set("displayName", m.displayName)
      .set("role", m.role.to!string)
      .set("joinedAt", m.joinedAt);
  }
  j["members"] = members;

  // Settings
  auto sj = Json.emptyObject
    .set("allowExternalMembers", w.settings.allowExternalMembers)
    .set("enableNotifications", w.settings.enableNotifications)
    .set("enableFeeds", w.settings.enableFeeds)
    .set("enableWiki", w.settings.enableWiki)
    .set("enableKnowledgeBase", w.settings.enableKnowledgeBase)
    .set("enableForum", w.settings.enableForum)
    .set("defaultLanguage", w.settings.defaultLanguage);

  j["settings"] = sj;

  return j;
}
