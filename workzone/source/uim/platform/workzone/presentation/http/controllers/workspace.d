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

class WorkspaceController {
  private ManageWorkspacesUseCase useCase;

  this(ManageWorkspacesUseCase useCase)
  {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router)
  {
    router.post("/api/v1/workspaces", &handleCreate);
    router.get("/api/v1/workspaces", &handleList);
    router.get("/api/v1/workspaces/*", &handleGet);
    router.put("/api/v1/workspaces/*", &handleUpdate);
    router.delete_("/api/v1/workspaces/*", &handleDelete);
    router.post("/api/v1/workspaces/members", &handleAddMember);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto j = req.json;
      auto r = CreateWorkspaceRequest();
      r.tenantId = req.headers.get("X-Tenant-Id", "");
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
      if (result.isSuccess())
      {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      }
      else
      {
        writeError(res, 400, result.error);
      }
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto workspaces = useCase.listWorkspaces(tenantId);
      auto arr = Json.emptyArray;
      foreach (ref w; workspaces)
        arr ~= serializeWorkspace(w);
      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) workspaces.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      // Check for sub-resources
      if (id == "members")
      {
        handleAddMember(req, res);
        return;
      }

      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto ws = useCase.getWorkspace(id, tenantId);
      if (ws is null)
      {
        writeError(res, 404, "Workspace not found");
        return;
      }
      res.writeJsonBody(serializeWorkspace(*ws), 200);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto j = req.json;
      auto r = UpdateWorkspaceRequest();
      r.id = extractIdFromPath(req.requestURI);
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.imageUrl = j.getString("imageUrl");
      r.settings = parseWorkspaceSettings(j);

      auto result = useCase.updateWorkspace(r);
      if (result.isSuccess())
      {
        auto resp = Json.emptyObject;
        resp["status"] = Json("updated");
        res.writeJsonBody(resp, 200);
      }
      else
      {
        writeError(res, 404, result.error);
      }
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      useCase.deleteWorkspace(id, tenantId);
      res.writeBody("", 204);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleAddMember(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto j = req.json;
      auto r = AddMemberRequest();
      r.workspaceId = j.getString("workspaceId");
      r.tenantId = req.headers.get("X-Tenant-Id", "");
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
      if (result.isSuccess())
      {
        auto resp = Json.emptyObject;
        resp["status"] = Json("member_added");
        res.writeJsonBody(resp, 200);
      }
      else
      {
        writeError(res, 400, result.error);
      }
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }
}

private WorkspaceSettings parseWorkspaceSettings(Json j) {
  WorkspaceSettings s;
  auto sv = "settings" in j;
  if (sv !is null && (*sv).type == Json.Type.object)
  {
    auto sj = *sv;
    s.allowExternalMembers = jsonBool(sj, "allowExternalMembers");
    s.enableNotifications = jsonBool(sj, "enableNotifications", true);
    s.enableFeeds = jsonBool(sj, "enableFeeds", true);
    s.enableWiki = jsonBool(sj, "enableWiki", true);
    s.enableKnowledgeBase = jsonBool(sj, "enableKnowledgeBase", true);
    s.enableForum = jsonBool(sj, "enableForum");
    s.defaultLanguage = jsonStr(sj, "defaultLanguage");
  }
  return s;
}

private Json serializeWorkspace(ref Workspace w) {
  // import std.conv : to;

  auto j = Json.emptyObject;
  j["id"] = Json(w.id);
  j["tenantId"] = Json(w.tenantId);
  j["name"] = Json(w.name);
  j["description"] = Json(w.description);
  j["alias"] = Json(w.alias_);
  j["type"] = Json(w.type.to!string);
  j["status"] = Json(w.status.to!string);
  j["imageUrl"] = Json(w.imageUrl);
  j["createdAt"] = Json(w.createdAt);
  j["updatedAt"] = Json(w.updatedAt);
  j["createdBy"] = Json(w.createdBy);

  // Members
  auto members = Json.emptyArray;
  foreach (ref m; w.members)
  {
    auto mj = Json.emptyObject;
    mj["userId"] = Json(m.userId);
    mj["displayName"] = Json(m.displayName);
    mj["role"] = Json(m.role.to!string);
    mj["joinedAt"] = Json(m.joinedAt);
    members ~= mj;
  }
  j["members"] = members;

  // Settings
  auto sj = Json.emptyObject;
  sj["allowExternalMembers"] = Json(w.settings.allowExternalMembers);
  sj["enableNotifications"] = Json(w.settings.enableNotifications);
  sj["enableFeeds"] = Json(w.settings.enableFeeds);
  sj["enableWiki"] = Json(w.settings.enableWiki);
  sj["enableKnowledgeBase"] = Json(w.settings.enableKnowledgeBase);
  sj["enableForum"] = Json(w.settings.enableForum);
  sj["defaultLanguage"] = Json(w.settings.defaultLanguage);
  j["settings"] = sj;

  return j;
}
