module presentation.http.package;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import std.conv : to;

import application.usecases.manage_content_packages;
import application.dto;
import domain.entities.content_package;
import domain.types;
import presentation.http.json_utils;

class PackageController : SAPController {
    private ManageContentPackagesUseCase uc;

    this(ManageContentPackagesUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.post("/api/v1/packages", &handleCreate);
        router.get("/api/v1/packages", &handleList);
        router.get("/api/v1/packages/*", &handleGetById);
        router.put("/api/v1/packages/*", &handleUpdate);
        router.delete_("/api/v1/packages/*", &handleDelete);
        router.post("/api/v1/packages/assemble", &handleAssemble);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            auto r = CreatePackageRequest();
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.subaccountId = req.headers.get("X-Subaccount-Id", "");
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.version_ = j.getString("version");
            r.format = j.getString("format");
            r.tags = jsonStrArray(j, "tags");
            r.createdBy = req.headers.get("X-User-Id", "");
            r.items = parseContentItems(j);

            auto result = uc.createPackage(r);
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

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.headers.get("X-Tenant-Id", "");
            auto packages = uc.listPackages(tenantId);

            auto arr = Json.emptyArray;
            foreach (ref p; packages)
                arr ~= serializePackage(p);

            auto resp = Json.emptyObject;
            resp["items"] = arr;
            resp["totalCount"] = Json(cast(long)packages.length);
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto id = extractIdFromPath(req.requestURI);
            auto pkg = uc.getPackage(id);
            if (pkg.id.length == 0) {
                writeError(res, 404, "Package not found");
                return;
            }
            res.writeJsonBody(serializePackage(pkg), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto id = extractIdFromPath(req.requestURI);
            auto j = req.json;
            auto r = UpdatePackageRequest();
            r.description = j.getString("description");
            r.version_ = j.getString("version");
            r.tags = jsonStrArray(j, "tags");
            r.items = parseContentItems(j);

            auto result = uc.updatePackage(id, r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, result.error == "Package not found" ? 404 : 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto id = extractIdFromPath(req.requestURI);
            auto result = uc.deletePackage(id);
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

    private void handleAssemble(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            auto r = AssemblePackageRequest();
            r.packageId = j.getString("packageId");
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.assembledBy = req.headers.get("X-User-Id", "");

            auto result = uc.assemblePackage(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["status"] = Json("assembled");
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private static ContentItem[] parseContentItems(Json j) {
        ContentItem[] items;
        auto v = "items" in j;
        if (v is null || (*v).type != Json.Type.array)
            return items;

        foreach (itemJson; *v) {
            if (itemJson.type != Json.Type.object)
                continue;
            ContentItem item;
            item.id = itemJson.getString("id");
            item.name = itemJson.getString("name");
            item.providerId = itemJson.getString("providerId");
            item.version_ = itemJson.getString("version");
            item.description = itemJson.getString("description");
            item.dependencies = jsonStrArray(itemJson, "dependencies");

            auto catStr = itemJson.getString("category");
            item.category = parseContentCategory(catStr);
            items ~= item;
        }
        return items;
    }

    private static ContentCategory parseContentCategory(string s) {
        switch (s) {
        case "integrationFlow":
            return ContentCategory.integrationFlow;
        case "destination":
            return ContentCategory.destination;
        case "apiProxy":
            return ContentCategory.apiProxy;
        case "valueMapping":
            return ContentCategory.valueMapping;
        case "securityArtifact":
            return ContentCategory.securityArtifact;
        case "messageMapping":
            return ContentCategory.messageMapping;
        case "scriptCollection":
            return ContentCategory.scriptCollection;
        case "dataType":
            return ContentCategory.dataType;
        case "messageType":
            return ContentCategory.messageType;
        case "numberRange":
            return ContentCategory.numberRange;
        case "customForm":
            return ContentCategory.customForm;
        case "workflow":
            return ContentCategory.workflow;
        case "businessRule":
            return ContentCategory.businessRule;
        case "keyValueMap":
            return ContentCategory.keyValueMap;
        case "oauthCredential":
            return ContentCategory.oauthCredential;
        case "certificateToUserMapping":
            return ContentCategory.certificateToUserMapping;
        case "accessPolicy":
            return ContentCategory.accessPolicy;
        case "functionLibrary":
            return ContentCategory.functionLibrary;
        default:
            return ContentCategory.custom;
        }
    }

    private static Json serializePackage(ref const ContentPackage p) {
        auto j = Json.emptyObject;
        j["id"] = Json(p.id);
        j["tenantId"] = Json(p.tenantId);
        j["subaccountId"] = Json(p.subaccountId);
        j["name"] = Json(p.name);
        j["description"] = Json(p.description);
        j["version"] = Json(p.version_);
        j["status"] = Json(p.status.to!string);
        j["format"] = Json(p.format.to!string);
        j["createdBy"] = Json(p.createdBy);
        j["createdAt"] = Json(p.createdAt);
        j["updatedAt"] = Json(p.updatedAt);
        j["assembledAt"] = Json(p.assembledAt);
        j["packageSizeBytes"] = Json(p.packageSizeBytes);

        if (p.items.length > 0) {
            auto arr = Json.emptyArray;
            foreach (ref item; p.items) {
                auto ij = Json.emptyObject;
                ij["id"] = Json(item.id);
                ij["name"] = Json(item.name);
                ij["category"] = Json(item.category.to!string);
                ij["providerId"] = Json(item.providerId);
                ij["version"] = Json(item.version_);
                ij["description"] = Json(item.description);
                ij["dependencies"] = toJsonArray(item.dependencies);
                arr ~= ij;
            }
            j["items"] = arr;
        }

        if (p.tags.length > 0)
            j["tags"] = toJsonArray(p.tags);

        return j;
    }
}
