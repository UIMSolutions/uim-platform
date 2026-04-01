module uim.platform.cloud_foundry.presentation.http.controllers.buildpack;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import std.conv : to;

import uim.platform.cloud_foundry.application.usecases.manage_buildpacks;
import uim.platform.cloud_foundry.application.dto;
import uim.platform.cloud_foundry.domain.types;
import uim.platform.cloud_foundry.domain.entities.buildpack;
import presentation.http.json_utils;

class BuildpackController
{
  private ManageBuildpacksUseCase useCase;

  this(ManageBuildpacksUseCase useCase)
  {
    this.useCase = useCase;
  }

  void registerRoutes(URLRouter router)
  {
    router.post("/api/v1/buildpacks", &handleCreate);
    router.get("/api/v1/buildpacks", &handleList);
    router.get("/api/v1/buildpacks/*", &handleGetById);
    router.put("/api/v1/buildpacks/*", &handleUpdate);
    router.delete_("/api/v1/buildpacks/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto j = req.json;
      auto r = CreateBuildpackRequest();
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.name = jsonStr(j, "name");
      r.type_ = parseBuildpackType(jsonStr(j, "type"));
      r.position = j.getInteger("position");
      r.stack = jsonStr(j, "stack");
      r.filename = jsonStr(j, "filename");
      r.createdBy = jsonStr(j, "createdBy");

      auto result = useCase.createBuildpack(r);
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
      auto items = useCase.listBuildpacks(tenantId);

      auto arr = Json.emptyArray;
      foreach (ref bp; items)
        arr ~= serializeBuildpack(bp);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) items.length);
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
      auto bp = useCase.getBuildpack(id, tenantId);
      if (bp is null)
      {
        writeError(res, 404, "Buildpack not found");
        return;
      }
      res.writeJsonBody(serializeBuildpack(*bp), 200);
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
      auto r = UpdateBuildpackRequest();
      r.id = id;
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.name = jsonStr(j, "name");
      r.position = j.getInteger("position");
      r.stack = jsonStr(j, "stack");
      r.filename = jsonStr(j, "filename");
      r.enabled = jsonBool(j, "enabled", true);
      r.locked = jsonBool(j, "locked");

      auto result = useCase.updateBuildpack(r);
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
      auto result = useCase.deleteBuildpack(id, tenantId);
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

  private static Json serializeBuildpack(ref const Buildpack bp)
  {
    auto j = Json.emptyObject;
    j["id"] = Json(bp.id);
    j["tenantId"] = Json(bp.tenantId);
    j["name"] = Json(bp.name);
    j["type"] = Json(bp.type_.to!string);
    j["position"] = Json(bp.position);
    j["stack"] = Json(bp.stack);
    j["filename"] = Json(bp.filename);
    j["enabled"] = Json(bp.enabled);
    j["locked"] = Json(bp.locked);
    j["createdBy"] = Json(bp.createdBy);
    j["createdAt"] = Json(bp.createdAt);
    j["updatedAt"] = Json(bp.updatedAt);
    return j;
  }
}
