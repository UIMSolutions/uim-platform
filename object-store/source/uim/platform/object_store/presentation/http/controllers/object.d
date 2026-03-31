module uim.platform.object_store.presentation.http.controllers.object;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import std.conv : to;

import uim.platform.object_store.application.use_cases.manage_objects;
import uim.platform.object_store.application.dto;
import uim.platform.object_store.domain.entities.storage_object;
import uim.platform.object_store.domain.entities.object_version;
import uim.platform.object_store.presentation.http.json_utils;

class ObjectController
{
    private ManageObjectsUseCase uc;

    this(ManageObjectsUseCase uc)
    {
        this.uc = uc;
    }

    void registerRoutes(URLRouter router)
    {
        router.post("/api/v1/objects", &handleCreate);
        router.get("/api/v1/buckets/*/objects", &handleListByBucket);
        router.get("/api/v1/objects/*", &handleGetById);
        router.put("/api/v1/objects/*", &handleUpdateMetadata);
        router.delete_("/api/v1/objects/*", &handleDelete);
        router.post("/api/v1/objects/copy", &handleCopy);
        router.get("/api/v1/objects/*/versions", &handleListVersions);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            auto r = CreateObjectRequest();
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.bucketId = jsonStr(j, "bucketId");
            r.key = jsonStr(j, "key");
            r.contentType = jsonStr(j, "contentType");
            r.size = jsonLong(j, "size");
            r.metadata = jsonStr(j, "metadata");
            r.storageClass = jsonStr(j, "storageClass");
            r.createdBy = req.headers.get("X-User-Id", "");

            auto result = uc.createObject(r);
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
            // Extract bucket ID from: /api/v1/buckets/{bucketId}/objects
            auto path = req.requestURI;
            auto bucketId = extractBucketIdFromPath(path);
            auto prefix = queryParam(req, "prefix");

            StorageObject[] objects;
            if (prefix.length > 0)
                objects = uc.listObjectsByPrefix(bucketId, prefix);
            else
                objects = uc.listObjects(bucketId);

            auto arr = Json.emptyArray;
            foreach (ref o; objects)
                arr ~= serializeObject(o);

            auto resp = Json.emptyObject;
            resp["items"] = arr;
            resp["totalCount"] = Json(cast(long) objects.length);
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
            // Check if this is a versions request
            if (id == "versions" || id == "copy")
                return;

            auto obj = uc.getObject(id);
            if (obj is null || obj.id.length == 0)
            {
                writeError(res, 404, "Object not found");
                return;
            }
            res.writeJsonBody(serializeObject(obj), 200);
        }
        catch (Exception e)
        {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleUpdateMetadata(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto id = extractIdFromPath(req.requestURI);
            auto j = req.json;
            auto r = UpdateObjectMetadataRequest();
            r.contentType = jsonStr(j, "contentType");
            r.metadata = jsonStr(j, "metadata");
            r.storageClass = jsonStr(j, "storageClass");

            auto result = uc.updateObjectMetadata(id, r);
            if (result.success)
            {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                res.writeJsonBody(resp, 200);
            }
            else
            {
                writeError(res, result.error == "Object not found" ? 404 : 400, result.error);
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
            auto result = uc.deleteObject(id);
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

    private void handleCopy(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            auto r = CopyObjectRequest();
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.sourceBucketId = jsonStr(j, "sourceBucketId");
            r.sourceKey = jsonStr(j, "sourceKey");
            r.destBucketId = jsonStr(j, "destBucketId");
            r.destKey = jsonStr(j, "destKey");
            r.createdBy = req.headers.get("X-User-Id", "");

            auto result = uc.copyObject(r);
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

    private void handleListVersions(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            // /api/v1/objects/{objectId}/versions
            auto path = req.requestURI;
            auto objectId = extractObjectIdFromVersionsPath(path);

            auto versions = uc.listVersions(objectId);

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

    private static Json serializeObject(StorageObject o)
    {
        auto j = Json.emptyObject;
        j["id"] = Json(o.id);
        j["tenantId"] = Json(o.tenantId);
        j["bucketId"] = Json(o.bucketId);
        j["key"] = Json(o.key);
        j["contentType"] = Json(o.contentType);
        j["size"] = Json(o.size);
        j["etag"] = Json(o.etag);
        j["metadata"] = Json(o.metadata);
        j["storageClass"] = Json(o.storageClass.to!string);
        j["status"] = Json(o.status.to!string);
        j["currentVersionId"] = Json(o.currentVersionId);
        j["createdBy"] = Json(o.createdBy);
        j["createdAt"] = Json(o.createdAt);
        j["updatedAt"] = Json(o.updatedAt);
        return j;
    }

    private static Json serializeVersion(ObjectVersion v)
    {
        auto j = Json.emptyObject;
        j["id"] = Json(v.id);
        j["objectId"] = Json(v.objectId);
        j["versionTag"] = Json(v.versionTag);
        j["size"] = Json(v.size);
        j["etag"] = Json(v.etag);
        j["contentType"] = Json(v.contentType);
        j["isLatest"] = Json(v.isLatest);
        j["isDeleteMarker"] = Json(v.isDeleteMarker);
        j["createdBy"] = Json(v.createdBy);
        j["createdAt"] = Json(v.createdAt);
        return j;
    }

    /// Extract bucket ID from /api/v1/buckets/{id}/objects
    private static string extractBucketIdFromPath(string uri)
    {
        import std.string : indexOf;
        // Remove query string
        auto qpos = uri.indexOf('?');
        string path = qpos >= 0 ? uri[0 .. qpos] : uri;

        // Find "buckets/" and extract next segment
        auto bucketsPos = path.indexOf("buckets/");
        if (bucketsPos < 0)
            return "";
        auto start = bucketsPos + 8;  // length of "buckets/"
        auto rest = path[start .. $];
        auto slashPos = rest.indexOf('/');
        if (slashPos > 0)
            return rest[0 .. slashPos];
        return rest;
    }

    /// Extract object ID from /api/v1/objects/{id}/versions
    private static string extractObjectIdFromVersionsPath(string uri)
    {
        import std.string : indexOf;
        auto qpos = uri.indexOf('?');
        string path = qpos >= 0 ? uri[0 .. qpos] : uri;

        auto objectsPos = path.indexOf("objects/");
        if (objectsPos < 0)
            return "";
        auto start = objectsPos + 8;
        auto rest = path[start .. $];
        auto slashPos = rest.indexOf('/');
        if (slashPos > 0)
            return rest[0 .. slashPos];
        return rest;
    }
}
