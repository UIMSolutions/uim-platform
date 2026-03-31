module presentation.http.version_controller;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import std.conv : to;

import application.usecases.manage_versions;
import application.dto;
import domain.entities.document_version;
import domain.types;
import presentation.http.json_utils;

class VersionController
{
  private ManageVersionsUseCase uc;

  this(ManageVersionsUseCase uc)
  {
    this.uc = uc;
  }

  void registerRoutes(URLRouter router)
  {
    router.post("/api/v1/versions/checkout/*", &handleCheckOut);
    router.post("/api/v1/versions/checkin", &handleCheckIn);
    router.post("/api/v1/versions/cancel-checkout/*", &handleCancelCheckOut);
    router.get("/api/v1/versions/document/*", &handleGetAllVersions);
    router.get("/api/v1/versions/current/*", &handleGetCurrentVersion);
  }

  private void handleCheckOut(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto docId = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto userId = req.headers.get("X-User-Id", "system");

      auto result = uc.checkOut(docId, tenantId, userId);
      if (result.isSuccess)
      {
        auto resp = Json.emptyObject;
        resp["documentId"] = Json(docId);
        resp["status"] = Json("locked");
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

  private void handleCheckIn(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto j = req.json;
      auto r = CheckInRequest();
      r.documentId = jsonStr(j, "documentId");
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.userId = req.headers.get("X-User-Id", "system");
      r.isMajor = jsonBool(j, "isMajor", true);
      r.comment = jsonStr(j, "comment");
      r.fileName = jsonStr(j, "fileName");
      r.mimeType = jsonStr(j, "mimeType");
      r.fileSize = jsonLong(j, "fileSize");
      r.checksum = jsonStr(j, "checksum");

      auto result = uc.checkIn(r);
      if (result.isSuccess)
      {
        auto resp = Json.emptyObject;
        resp["versionId"] = Json(result.id);
        resp["documentId"] = Json(r.documentId);
        resp["status"] = Json("active");
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

  private void handleCancelCheckOut(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto docId = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");

      auto result = uc.cancelCheckOut(docId, tenantId);
      if (result.isSuccess)
      {
        auto resp = Json.emptyObject;
        resp["documentId"] = Json(docId);
        resp["status"] = Json("active");
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

  private void handleGetAllVersions(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto docId = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto versions = uc.getAllVersions(docId, tenantId);

      auto arr = Json.emptyArray;
      foreach (ref v; versions)
        arr ~= serializeVersion(v);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) versions.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetCurrentVersion(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto docId = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto ver = uc.getCurrentVersion(docId, tenantId);
      if (ver is null)
      {
        writeError(res, 404, "No current version found");
        return;
      }
      res.writeJsonBody(serializeVersion(ver), 200);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeVersion(const DocumentVersion v)
  {
    auto j = Json.emptyObject;
    j["id"] = Json(v.id);
    j["tenantId"] = Json(v.tenantId);
    j["documentId"] = Json(v.documentId);
    j["versionNumber"] = Json(v.versionNumber);
    j["isMajor"] = v.isMajor ? Json(true) : Json(false);
    j["fileName"] = Json(v.fileName);
    j["mimeType"] = Json(v.mimeType);
    j["fileSize"] = Json(v.fileSize);
    j["status"] = Json(v.status.to!string);
    j["comment"] = Json(v.comment);
    j["checksum"] = Json(v.checksum);
    j["createdBy"] = Json(v.createdBy);
    j["createdAt"] = Json(v.createdAt);
    return j;
  }
}
