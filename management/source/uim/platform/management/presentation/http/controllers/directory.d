module uim.platform.management.presentation.http.controllers.directory;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// 
// import uim.platform.management.application.usecases.manage_directories;
// import uim.platform.management.application.dto;
// import uim.platform.management.domain.entities.directory;
// import uim.platform.management.domain.types;
// import presentation.http.json_utils;
import uim.platform.management;

mixin(ShowModule!());
@safe:
class DirectoryController : SAPController {
    private ManageDirectoriesUseCase uc;

    this(ManageDirectoriesUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.post("/api/v1/directories", &handleCreate);
        router.get("/api/v1/directories", &handleList);
        router.get("/api/v1/directories/*", &handleGet);
        router.put("/api/v1/directories/*", &handleUpdate);
        router.delete_("/api/v1/directories/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            CreateDirectoryRequest r;
            r.globalAccountId = j.getString("globalAccountId");
            r.parentDirectoryId = j.getString("parentDirectoryId");
            r.displayName = j.getString("displayName");
            r.description = j.getString("description");
            r.features = jsonStrArray(j, "features");
            r.manageEntitlements = j.getBoolean("manageEntitlements");
            r.manageAuthorizations = j.getBoolean("manageAuthorizations");
            r.createdBy = req.headers.get("X-User-Id", "");
            r.labels = jsonStrMap(j, "labels");
            r.customProperties = jsonStrMap(j, "customProperties");

            auto result = uc.create(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                res.writeJsonBody(resp, 201);
            } else
                writeError(res, 400, result.error);
        } catch (Exception e)
            writeError(res, 500, "Internal server error");
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto gaId = req.params.get("globalAccountId");
            auto parentId = req.params.get("parentDirectoryId");

            Directory[] items;
            if (parentId.length > 0)
                items = uc.listByParent(parentId);
            else if (gaId.length > 0)
                items = uc.listByGlobalAccount(gaId);

            auto arr = Json.emptyArray;
            foreach (ref d; items)
                arr ~= serializeDirectory(d);

            auto resp = Json.emptyObject;
            resp["items"] = arr;
            resp["totalCount"] = Json(cast(long)items.length);
            res.writeJsonBody(resp, 200);
        } catch (Exception e)
            writeError(res, 500, "Internal server error");
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto id = extractId(req.requestURI);
            auto d = uc.getById(id);
            if (d.id.length == 0) {
                writeError(res, 404, "Directory not found");
                return;
            }
            res.writeJsonBody(serializeDirectory(d), 200);
        } catch (Exception e)
            writeError(res, 500, "Internal server error");
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto id = extractId(req.requestURI);
            auto j = req.json;
            UpdateDirectoryRequest r;
            r.displayName = j.getString("displayName");
            r.description = j.getString("description");
            r.labels = jsonStrMap(j, "labels");
            r.customProperties = jsonStrMap(j, "customProperties");

            auto result = uc.update(id, r);
            if (result.success)
                res.writeJsonBody(Json.emptyObject, 200);
            else
                writeError(res, 404, result.error);
        } catch (Exception e)
            writeError(res, 500, "Internal server error");
    }

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto id = extractId(req.requestURI);
            auto result = uc.remove(id);
            if (result.success)
                res.writeJsonBody(Json.emptyObject, 204);
            else
                writeError(res, 400, result.error);
        } catch (Exception e)
            writeError(res, 500, "Internal server error");
    }
}

private Json serializeDirectory(ref Directory d) {
    auto j = Json.emptyObject;
    j["id"] = Json(d.id);
    j["globalAccountId"] = Json(d.globalAccountId);
    j["parentDirectoryId"] = Json(d.parentDirectoryId);
    j["displayName"] = Json(d.displayName);
    j["description"] = Json(d.description);
    j["status"] = Json(enumStr(d.status));
    j["manageEntitlements"] = Json(d.manageEntitlements);
    j["manageAuthorizations"] = Json(d.manageAuthorizations);
    j["createdBy"] = Json(d.createdBy);
    j["createdAt"] = Json(d.createdAt);
    j["modifiedAt"] = Json(d.modifiedAt);
    j["labels"] = serializeStrMap(d.labels);
    j["customProperties"] = serializeStrMap(d.customProperties);
    j["subaccounts"] = serializeStrArray(d.subaccounts);
    j["subdirectories"] = serializeStrArray(d.subdirectories);
    return j;
}

private string enumStr(E)(E val) {
    import std.conv : to;

    return val.to!string;
}
