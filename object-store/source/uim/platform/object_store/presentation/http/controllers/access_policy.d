/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.presentation.http.controllers.access_policy;

// 
// 
// import uim.platform.object_store.application.usecases.manage.access_policies;
// import uim.platform.object_store.application.dto;
// import uim.platform.object_store.domain.entities.access_policy;

import uim.platform.object_store;

mixin(ShowModule!());

@safe:
class AccessPolicyController : PlatformController {
  private ManageAccessPoliciesUseCase usecase;

  this(ManageAccessPoliciesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/access-policies", &handleCreate);
    router.get("/api/v1/buckets/*/access-policies", &handleListByBucket);
    router.get("/api/v1/access-policies/*", &handleGet);
    router.put("/api/v1/access-policies/*", &handleUpdate);
    router.delete_("/api/v1/access-policies/*", &handleDelete);
  }

  protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      
      auto r = CreateAccessPolicyRequest();
      r.tenantId = tenantId;
      r.bucketId = j.getString("bucketId");
      r.name = j.getString("name");
      r.effect = j.getString("effect");
      r.principal = j.getString("principal");
      r.actions = j.getString("actions");
      r.resources = j.getString("resources");
      r.createdBy = UserId(req.headers.get("X-User-Id", ""));

      auto result = usecase.createPolicy(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Access policy created successfully");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleListByBucket(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto bucketId = extractBucketIdFromPoliciesPath(req.requestURI);
      auto policies = usecase.listPolicies(tenantId, bucketId);

      auto arr = policies.map!(p => p.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", policies.length)
        .set("message", "Access policies retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = AccessPolicyId(extractIdFromPath(req.requestURI));
      auto policy = usecase.getPolicy(tenantId, id);
      if (policy.isNull) {
        writeError(res, 404, "Access policy not found");
        return;
      }
      res.writeJsonBody(policy.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = AccessPolicyId(extractIdFromPath(req.requestURI));
      auto j = req.json;

      UpdateAccessPolicyRequest r;
      r.tenantId = tenantId;
      r.accessPolicyId = id;
      r.name = j.getString("name");
      r.effect = j.getString("effect");
      r.principal = j.getString("principal");
      r.actions = j.getString("actions");
      r.resources = j.getString("resources");

      auto result = usecase.updatePolicy(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Access policy updated successfully");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, result.message == "Policy not found" ? 404 : 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = AccessPolicyId(extractIdFromPath(req.requestURI));
      auto result = usecase.deletePolicy(tenantId, id);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("deleted", true)
          .set("message", "Access policy deleted successfully");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.message);
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
