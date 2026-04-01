module uim.platform.object_store.presentation.http.controllers.lifecycle_rule;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;

// import uim.platform.object_store.application.use_cases.manage_lifecycle_rules;
// import uim.platform.object_store.application.dto;
// import uim.platform.object_store.domain.entities.lifecycle_rule;
// import uim.platform.object_store.presentation.http.json_utils;

import uim.platform.object_store;

mixin(ShowModule!());

@safe:
class LifecycleRuleController : SAPController {
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
            auto r = CreateLifecycleRuleRequest();
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.bucketId = j.getString("bucketId");
            r.name = j.getString("name");
            r.prefix = j.getString("prefix");
            r.status = j.getString("status");
            r.expirationDays = j.getInteger("expirationDays");
            r.transitionDays = j.getInteger("transitionDays");
            r.transitionStorageClass = j.getString("transitionStorageClass");
            r.abortIncompleteUploadDays = j.getInteger("abortIncompleteUploadDays");
            r.createdBy = req.headers.get("X-User-Id", "");

            auto result = uc.createRule(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
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

            auto arr = Json.emptyArray;
            foreach (ref r; rules)
                arr ~= serializeRule(r);

            auto resp = Json.emptyObject;
            resp["items"] = arr;
            resp["totalCount"] = Json(cast(long)rules.length);
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto id = extractIdFromPath(req.requestURI);
            auto rule = uc.getRule(id);
            if (rule is null || rule.id.length == 0) {
                writeError(res, 404, "Lifecycle rule not found");
                return;
            }
            res.writeJsonBody(serializeRule(rule), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto id = extractIdFromPath(req.requestURI);
            auto j = req.json;
            auto r = UpdateLifecycleRuleRequest();
            r.name = j.getString("name");
            r.prefix = j.getString("prefix");
            r.status = j.getString("status");
            r.expirationDays = j.getInteger("expirationDays");
            r.transitionDays = j.getInteger("transitionDays");
            r.transitionStorageClass = j.getString("transitionStorageClass");
            r.abortIncompleteUploadDays = j.getInteger("abortIncompleteUploadDays");

            auto result = uc.updateRule(id, r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
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
                auto resp = Json.emptyObject;
                resp["deleted"] = Json(true);
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private static Json serializeRule(LifecycleRule r) {
        auto j = Json.emptyObject;
        j["id"] = Json(r.id);
        j["tenantId"] = Json(r.tenantId);
        j["bucketId"] = Json(r.bucketId);
        j["name"] = Json(r.name);
        j["prefix"] = Json(r.prefix);
        j["status"] = Json(r.status.to!string);
        j["expirationDays"] = Json(cast(long)r.expirationDays);
        j["transitionDays"] = Json(cast(long)r.transitionDays);
        j["transitionStorageClass"] = Json(r.transitionStorageClass.to!string);
        j["abortIncompleteUploadDays"] = Json(cast(long)r.abortIncompleteUploadDays);
        j["createdBy"] = Json(r.createdBy);
        j["createdAt"] = Json(r.createdAt);
        j["updatedAt"] = Json(r.updatedAt);
        return j;
    }

    private static string extractBucketIdFromRulesPath(string uri) {
        import std.string : indexOf;

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
