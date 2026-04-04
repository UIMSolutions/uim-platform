/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.presentation.http.controllers.cors_rule;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;

import uim.platform.object_store.application.usecases.manage.cors_rules;
import uim.platform.object_store.application.dto;
import uim.platform.object_store.domain.entities.cors_rule;
import uim.platform.object_store.presentation.http.json_utils;

class CorsRuleController : SAPController
{
  private ManageCorsRulesUseCase uc;

  this(ManageCorsRulesUseCase uc)
  {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router)
  {
    super.registerRoutes(router);

    router.post("/api/v1/cors-rules", &handleCreate);
    router.get("/api/v1/buckets/*/cors-rules", &handleListByBucket);
    router.get("/api/v1/cors-rules/*", &handleGetById);
    router.put("/api/v1/cors-rules/*", &handleUpdate);
    router.delete_("/api/v1/cors-rules/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto j = req.json;
      auto r = CreateCorsRuleRequest();
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.bucketId = j.getString("bucketId");
      r.allowedOrigins = j.getString("allowedOrigins");
      r.allowedMethods = j.getString("allowedMethods");
      r.allowedHeaders = j.getString("allowedHeaders");
      r.exposedHeaders = j.getString("exposedHeaders");
      r.maxAgeSeconds = j.getInteger("maxAgeSeconds");

      auto result = uc.createRule(r);
      if (result.success)
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

  private void handleListByBucket(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto bucketId = extractBucketIdFromCorsPath(req.requestURI);
      auto rules = uc.listRules(bucketId);

      auto arr = rules.map!(r => serializeRule(r)).array.toJson;

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) rules.length);
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
      auto rule = uc.getRule(id);
      if (rule is null || rule.id.length == 0)
      {
        writeError(res, 404, "CORS rule not found");
        return;
      }
      res.writeJsonBody(serializeRule(rule), 200);
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
      auto r = UpdateCorsRuleRequest();
      r.allowedOrigins = j.getString("allowedOrigins");
      r.allowedMethods = j.getString("allowedMethods");
      r.allowedHeaders = j.getString("allowedHeaders");
      r.exposedHeaders = j.getString("exposedHeaders");
      r.maxAgeSeconds = j.getInteger("maxAgeSeconds");

      auto result = uc.updateRule(id, r);
      if (result.success)
      {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      }
      else
      {
        writeError(res, result.error == "CORS rule not found" ? 404 : 400, result.error);
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
      auto result = uc.deleteRule(id);
      if (result.success)
      {
        auto resp = Json.emptyObject;
        resp["deleted"] = Json(true);
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

  private static Json serializeRule(CorsRule r)
  {
    auto j = Json.emptyObject;
    j["id"] = Json(r.id);
    j["tenantId"] = Json(r.tenantId);
    j["bucketId"] = Json(r.bucketId);
    j["allowedOrigins"] = Json(r.allowedOrigins);
    j["allowedMethods"] = Json(r.allowedMethods);
    j["allowedHeaders"] = Json(r.allowedHeaders);
    j["exposedHeaders"] = Json(r.exposedHeaders);
    j["maxAgeSeconds"] = Json(cast(long) r.maxAgeSeconds);
    j["createdAt"] = Json(r.createdAt);
    j["updatedAt"] = Json(r.updatedAt);
    return j;
  }

  private static string extractBucketIdFromCorsPath(string uri)
  {
    // import std.string : indexOf;

    auto qpos = uri.indexOf('?');
    string path = qpos >= 0 ? uri[0 .. qpos] : uri;

    auto bucketsPos = path.indexOf("buckets/");
    if (bucketsPos < 0)
      return "";
    auto start = bucketsPos + 8;
    auto rest = path[start .. $];
    auto slashPos = rest.indexOf('/');
    if (slashPos > 0)
      return rest[0 .. slashPos];
    return rest;
  }
}
