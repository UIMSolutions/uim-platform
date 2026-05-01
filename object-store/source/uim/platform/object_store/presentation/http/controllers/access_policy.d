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
class AccessPolicyController : PlatformController {
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
    try {
      auto j = req.json;
      auto r = CreateAccessPolicyRequest();
      r.tenantId = req.getTenantId;
      r.bucketId = j.getString("bucketId");
      r.name = j.getString("name");
      r.effect = j.getString("effect");
      r.principal = j.getString("principal");
      r.actions = j.getString("actions");
      r.resources = j.getString("resources");
      r.createdBy = req.headers.get("X-User-Id", "");

      auto result = uc.createPolicy(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id);

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleListByBucket(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto bucketId = extractBucketIdFromPoliciesPath(req.requestURI);
      auto policies = uc.listPolicies(bucketId);

      auto arr = Json.emptyArray;
      foreach (p; policies)
        arr ~= serializePolicy(p);

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", policies.length);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto policy = uc.getPolicy(id);
      if (policy.isNull || policy.isNull) {
        writeError(res, 404, "Access policy not found");
        return;
      }
      res.writeJsonBody(serializePolicy(policy), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      auto r = UpdateAccessPolicyRequest();
      r.name = j.getString("name");
      r.effect = j.getString("effect");
      r.principal = j.getString("principal");
      r.actions = j.getString("actions");
      r.resources = j.getString("resources");

      auto result = uc.updatePolicy(id, r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id);

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, result.error == "Policy not found" ? 404 : 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto result = uc.deletePolicy(id);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("deleted", true)
          .set("message", "Access policy deleted successfully");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializePolicy(AccessPolicy p) {
    return Json.emptyObject
      .set("id", p.id)
      .set("tenantId", p.tenantId)
      .set("bucketId", p.bucketId)
      .set("name", p.name)
      .set("effect", p.effect.to!string)
      .set("principal", p.principal)
      .set("actions", p.actions)
      .set("resources", p.resources)
      .set("createdBy", p.createdBy)
      .set("createdAt", p.createdAt)
      .set("updatedAt", p.updatedAt);
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
