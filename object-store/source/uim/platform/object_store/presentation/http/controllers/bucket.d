module presentation.http.bucket_controller;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import std.conv : to;

import uim.platform.object_store.application.use_cases.manage_buckets;
import uim.platform.object_store.application.dto;
import domain.entities.bucket;
import presentation.http.json_utils;

class BucketController
{
    private ManageBucketsUseCase uc;

    this(ManageBucketsUseCase uc)
    {
        this.uc = uc;
    }

    void registerRoutes(URLRouter router)
    {
        router.post("/api/v1/buckets", &handleCreate);
        router.get("/api/v1/buckets", &handleList);
        router.get("/api/v1/buckets/*", &handleGetById);
        router.put("/api/v1/buckets/*", &handleUpdate);
        router.delete_("/api/v1/buckets/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            auto r = CreateBucketRequest();
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.name = jsonStr(j, "name");
            r.region = jsonStr(j, "region");
            r.storageClass = jsonStr(j, "storageClass");
            r.versioningEnabled = jsonBool(j, "versioningEnabled");
            r.encryptionType = jsonStr(j, "encryptionType");
            r.encryptionKeyId = jsonStr(j, "encryptionKeyId");
            r.quotaBytes = jsonLong(j, "quotaBytes");
            r.createdBy = req.headers.get("X-User-Id", "");

            auto result = uc.createBucket(r);
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

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto tenantId = req.headers.get("X-Tenant-Id", "");
            auto buckets = uc.listBuckets(tenantId);

            auto arr = Json.emptyArray;
            foreach (ref b; buckets)
                arr ~= serializeBucket(b);

            auto resp = Json.emptyObject;
            resp["items"] = arr;
            resp["totalCount"] = Json(cast(long) buckets.length);
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
            auto bucket = uc.getBucket(id);
            if (bucket is null || bucket.id.length == 0)
            {
                writeError(res, 404, "Bucket not found");
                return;
            }
            res.writeJsonBody(serializeBucket(bucket), 200);
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
            auto r = UpdateBucketRequest();
            r.storageClass = jsonStr(j, "storageClass");
            r.versioningEnabled = jsonBool(j, "versioningEnabled");
            r.encryptionType = jsonStr(j, "encryptionType");
            r.encryptionKeyId = jsonStr(j, "encryptionKeyId");
            r.quotaBytes = jsonLong(j, "quotaBytes");

            auto result = uc.updateBucket(id, r);
            if (result.success)
            {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                res.writeJsonBody(resp, 200);
            }
            else
            {
                writeError(res, result.error == "Bucket not found" ? 404 : 400, result.error);
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
            auto result = uc.deleteBucket(id);
            if (result.success)
            {
                auto resp = Json.emptyObject;
                resp["deleted"] = Json(true);
                res.writeJsonBody(resp, 200);
            }
            else
            {
                auto code = result.error == "Bucket not found" ? 404 : 409;
                writeError(res, code, result.error);
            }
        }
        catch (Exception e)
        {
            writeError(res, 500, "Internal server error");
        }
    }

    private static Json serializeBucket(Bucket b)
    {
        auto j = Json.emptyObject;
        j["id"] = Json(b.id);
        j["tenantId"] = Json(b.tenantId);
        j["name"] = Json(b.name);
        j["region"] = Json(b.region);
        j["storageClass"] = Json(b.storageClass.to!string);
        j["versioningEnabled"] = Json(b.versioningEnabled);
        j["encryptionType"] = Json(b.encryptionType.to!string);
        j["encryptionKeyId"] = Json(b.encryptionKeyId);
        j["status"] = Json(b.status.to!string);
        j["quotaBytes"] = Json(b.quotaBytes);
        j["usedBytes"] = Json(b.usedBytes);
        j["objectCount"] = Json(b.objectCount);
        j["createdBy"] = Json(b.createdBy);
        j["createdAt"] = Json(b.createdAt);
        j["updatedAt"] = Json(b.updatedAt);
        return j;
    }
}
