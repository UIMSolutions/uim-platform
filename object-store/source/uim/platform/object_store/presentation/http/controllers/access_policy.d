/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.presentation.http.controllers.access_policy;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// // import std.conv : to;
// 
// import uim.platform.object_store.application.usecases.manage.access_policies;
// import uim.platform.object_store.application.dto;
// import uim.platform.object_store.domain.entities.access_policy;
// import uim.platform.object_store.presentation.http.json_utils;

import uim.platform.object_store;

mixin(ShowModule!());

@safe:
class AccessPolicyController : SAPController {
  private ManageAccessPoliciesUseCase uc;

  this(ManageAccessPoliciesUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/access-policies", &handleCreate);
    router.get("/api/v1/buckets/*/access-policies", &handleListByBucket);
    router.get("/api/v1/access-policies/*", &handleGetById);
    router.put("/api/v1/access-policies/*", &handleUpdate);
    router.delete_("/api/v1/access-policies/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try
    {
      auto j = req.json;
      auto r = CreateAccessPolicyRequest();
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.bucketId = j.getString("bucketId");
      r.name = j.getString("name");
      r.effect = j.getString("effect");
      r.principal = j.getString("principal");
      r.actions = j.getString("actions");
      r.resources = j.getString("resources");
      r.createdBy = req.headers.get("X-User-Id", "");

      auto result = uc.createPolicy(r);
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

  private void handleListByBucket(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try
    {
      auto bucketId = extractBucketIdFromPoliciesPath(req.requestURI);
      auto policies = uc.listPolicies(bucketId);

      auto arr = Json.emptyArray;
      foreach (ref p; policies)
        arr ~= serializePolicy(p);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) policies.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto policy = uc.getPolicy(id);
      if (policy is null || policy.id.length == 0)
      {
        writeError(res, 404, "Access policy not found");
        return;
      }
      res.writeJsonBody(serializePolicy(policy), 200);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      auto r = UpdateAccessPolicyRequest();
      r.name = j.getString("name");
      r.effect = j.getString("effect");
      r.principal = j.getString("principal");
      r.actions = j.getString("actions");
      r.resources = j.getString("resources");

      auto result = uc.updatePolicy(id, r);
      if (result.success)
      {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      }
      else
      {
        writeError(res, result.error == "Policy not found" ? 404 : 400, result.error);
      }
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto result = uc.deletePolicy(id);
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

  private static Json serializePolicy(AccessPolicy p) {
    auto j = Json.emptyObject;
    j["id"] = Json(p.id);
    j["tenantId"] = Json(p.tenantId);
    j["bucketId"] = Json(p.bucketId);
    j["name"] = Json(p.name);
    j["effect"] = Json(p.effect.to!string);
    j["principal"] = Json(p.principal);
    j["actions"] = Json(p.actions);
    j["resources"] = Json(p.resources);
    j["createdBy"] = Json(p.createdBy);
    j["createdAt"] = Json(p.createdAt);
    j["updatedAt"] = Json(p.updatedAt);
    return j;
  }

  /// Extract bucket ID from /api/v1/buckets/{id}/access-policies
  private static string extractBucketIdFromPoliciesPath(string uri) {
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
