module uim.platform.foundry.presentation.http.controllers.space;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import std.conv : to;

import uim.platform.foundry.application.usecases.manage_spaces;
import uim.platform.foundry.application.dto;
import uim.platform.foundry.domain.types;
import uim.platform.foundry.domain.entities.space;
import uim.platform.xyz.presentation.http.json_utils;

class SpaceController
{
  private ManageSpacesUseCase useCase;

  this(ManageSpacesUseCase useCase)
  {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router)
  {
    router.post("/api/v1/spaces", &handleCreate);
    router.get("/api/v1/spaces", &handleList);
    router.get("/api/v1/spaces/*", &handleGetById);
    router.put("/api/v1/spaces/*", &handleUpdate);
    router.delete_("/api/v1/spaces/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto j = req.json;
      auto r = CreateSpaceRequest();
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.orgId = j.getString("orgId");
      r.name = j.getString("name");
      r.allowSsh = j.getBoolean("allowSsh", true);
      r.createdBy = j.getString("createdBy");

      auto result = useCase.createSpace(r);
      if (result.isSuccess())
      {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      }
      else
        writeError(res, 400, result.error);
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
      auto spaces = useCase.listSpaces(tenantId);

      auto arr = Json.emptyArray;
      foreach (ref s; spaces)
        arr ~= serializeSpace(s);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) spaces.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto space = useCase.getSpace(id, tenantId);
      if (space is null)
      {
        writeError(res, 404, "Space not found");
        return;
      }
      res.writeJsonBody(serializeSpace(*space), 200);
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
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      auto r = UpdateSpaceRequest();
      r.id = id;
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.name = j.getString("name");
      r.allowSsh = j.getBoolean("allowSsh", true);

      auto result = useCase.updateSpace(r);
      if (result.isSuccess())
      {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      }
      else
        writeError(res, 400, result.error);
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
      auto result = useCase.deleteSpace(id, tenantId);
      if (result.isSuccess())
      {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      }
      else
        writeError(res, 404, result.error);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeSpace(ref const Space s)
  {
    auto j = Json.emptyObject;
    j["id"] = Json(s.id);
    j["orgId"] = Json(s.orgId);
    j["tenantId"] = Json(s.tenantId);
    j["name"] = Json(s.name);
    j["status"] = Json(s.status.to!string);
    j["allowSsh"] = Json(s.allowSsh);
    j["createdBy"] = Json(s.createdBy);
    j["createdAt"] = Json(s.createdAt);
    j["updatedAt"] = Json(s.updatedAt);
    return j;
  }
}
