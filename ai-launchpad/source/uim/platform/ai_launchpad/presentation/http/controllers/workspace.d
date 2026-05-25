/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.presentation.http.controllers.workspace;

// import uim.platform.ai_launchpad.application.usecases.manage.workspaces;
// import uim.platform.ai_launchpad.application.dto;
import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

class WorkspaceController : ManageController {
  private ManageWorkspacesUseCase usecase;

  this(ManageWorkspacesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/workspaces", &handleCreate);
    router.get("/api/v1/workspaces", &handleList);
    router.get("/api/v1/workspaces/*", &handleGet);
    router.patch("/api/v1/workspaces/*", &handlePatch);
    router.delete_("/api/v1/workspaces/*", &handleDelete);
  }

  protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      CreateWorkspaceRequest r;
      r.tenantId = tenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");

      auto result = usecase.createWorkspace(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Workspace created");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;

      auto workspaces = usecase.listWorkspaces(tenantId);

      auto jarr = workspaces.map!(w => w.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("count", workspaces.length)
        .set("resources", jarr);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = WorkspaceId(extractIdFromPath(req.requestURI.to!string));

      auto w = usecase.getWorkspace(tenantId, id);
      if (w.isNull) {
        writeError(res, 404, "Workspace not found");
        return;
      }

      res.writeJsonBody(w.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handlePatch(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = WorkspaceId(extractIdFromPath(req.requestURI.to!string));
      auto j = req.json;

      PatchWorkspaceRequest r;
      r.workspaceId = id;
      r.tenantId = tenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");

      auto result = usecase.patchWorkspace(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("message", "Workspace updated");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = WorkspaceId(extractIdFromPath(req.requestURI.to!string));

      auto result = usecase.deleteWorkspace(tenantId, id);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("message", "Workspace deleted");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
