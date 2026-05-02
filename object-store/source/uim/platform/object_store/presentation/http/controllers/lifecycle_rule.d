/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.presentation.http.controllers.lifecycle_rule;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// // import std.conv : to;

// import uim.platform.object_store.application.usecases.manage.lifecycle_rules;
// import uim.platform.object_store.application.dto;
// import uim.platform.object_store.domain.entities.lifecycle_rule;

import uim.platform.object_store;

mixin(ShowModule!());

@safe:
class LifecycleRuleController : PlatformController {
  private ManageLifecycleRulesUseCase uc;

  this(ManageLifecycleRulesUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/lifecycle-rules", &handleCreate);
    router.get("/api/v1/buckets/*/lifecycle-rules", &handleListByBucket);
    router.get("/api/v1/lifecycle-rules/*", &handleGetById);
    router.put("/api/v1/lifecycle-rules/*", &handleUpdate);
    router.delete_("/api/v1/lifecycle-rules/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto request = CreateLifecycleRuleRequest();
      request.tenantId = request.getTenantId;
      request.bucketId = j.getString("bucketId");
      request.name = j.getString("name");
      request.prefix = j.getString("prefix");
      request.status = j.getString("status");
      request.expirationDays = j.getInteger("expirationDays");
      request.transitionDays = j.getInteger("transitionDays");
      request.transitionStorageClass = j.getString("transitionStorageClass");
      request.abortIncompleteUploadDays = j.getInteger("abortIncompleteUploadDays");
      request.createdBy = req.headers.get("X-User-Id", "");

      auto result = uc.createRule(request);
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
      auto bucketId = extractBucketIdFromRulesPath(req.requestURI);
      auto rules = uc.listRules(bucketId);

      auto arr = rules.map!(r => serializeRule(r)).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", rules.length)
        .set("message", "Lifecycle rules retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto rule = uc.getRule(id);
      if (rule.isNull || rule.isNull) {
        writeError(res, 404, "Lifecycle rule not found");
        return;
      }
      res.writeJsonBody(rule.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      auto request = UpdateLifecycleRuleRequest();
      request.name = j.getString("name");
      request.prefix = j.getString("prefix");
      request.status = j.getString("status");
      request.expirationDays = j.getInteger("expirationDays");
      request.transitionDays = j.getInteger("transitionDays");
      request.transitionStorageClass = j.getString("transitionStorageClass");
      request.abortIncompleteUploadDays = j.getInteger("abortIncompleteUploadDays");

      auto result = uc.updateRule(id, request);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Lifecycle rule updated successfully");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, result.error == "Rule not found" ? 404 : 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto result = uc.deleteRule(id);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("deleted", true)
          .set("message", "Lifecycle rule deleted successfully");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeRule(LifecycleRule r) {
    return Json.emptyObject
      .set("id", r.id)
      .set("tenantId", r.tenantId)
      .set("bucketId", r.bucketId)
      .set("name", r.name)
      .set("prefix", r.prefix)
      .set("status", r.status.to!string)
      .set("expirationDays", r.expirationDays)
      .set("transitionDays", r.transitionDays)
      .set("transitionStorageClass", r.transitionStorageClass.to!string)
      .set("abortIncompleteUploadDays", r.abortIncompleteUploadDays)
      .set("createdBy", r.createdBy)
      .set("createdAt", r.createdAt)
      .set("updatedAt", r.updatedAt);
  }

  private static string extractBucketIdFromRulesPath(string uri) {
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
