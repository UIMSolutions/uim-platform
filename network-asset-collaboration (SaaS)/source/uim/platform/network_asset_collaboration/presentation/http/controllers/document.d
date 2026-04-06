/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.network_asset_collaboration.presentation.http.controllers.document;

import uim.platform.network_asset_collaboration;

mixin(ShowModule!());

@safe:

class DocumentController : SAPController {
    private ManageDocumentsUseCase uc;

    this(ManageDocumentsUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/network-asset-collaboration/documents", &handleList);
        router.get("/api/v1/network-asset-collaboration/documents/*", &handleGet);
        router.post("/api/v1/network-asset-collaboration/documents", &handleCreate);
        router.put("/api/v1/network-asset-collaboration/documents/*", &handleUpdate);
        router.delete_("/api/v1/network-asset-collaboration/documents/*", &handleDelete);
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto params = req.queryParams();
            auto equipmentId = params.get("equipmentId", "");
            auto modelId = params.get("modelId", "");

            Document[] items;
            if (equipmentId.length > 0) {
                items = uc.listByEquipment(equipmentId);
            } else if (modelId.length > 0) {
                items = uc.listByModel(modelId);
            } else {
                items = uc.list();
            }

            auto jarr = Json.emptyArray;
            foreach (ref d; items) jarr ~= documentToJson(d);
            auto resp = Json.emptyObject;
            resp["count"] = Json(cast(long) items.length);
            resp["resources"] = jarr;
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto path = req.requestURI.to!string;
            auto id = extractIdFromPath(path);
            auto d = uc.get_(id);
            if (d is null) { writeError(res, 404, "Document not found"); return; }
            res.writeJsonBody(documentToJson(*d), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            DocumentDTO dto;
            dto.id = jsonStr(j, "id");
            dto.tenantId = req.headers.get("X-Tenant-Id", "");
            dto.equipmentId = jsonStr(j, "equipmentId");
            dto.modelId = jsonStr(j, "modelId");
            dto.name = jsonStr(j, "name");
            dto.description = jsonStr(j, "description");
            dto.version_ = jsonStr(j, "version");
            dto.fileName = jsonStr(j, "fileName");
            dto.fileSize = jsonStr(j, "fileSize");
            dto.mimeType = jsonStr(j, "mimeType");
            dto.language = jsonStr(j, "language");
            dto.uploadedBy = jsonStr(j, "uploadedBy");
            dto.createdBy = jsonStr(j, "createdBy");

            auto result = uc.create(dto);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Document created");
                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto path = req.requestURI.to!string;
            auto j = req.json;
            DocumentDTO dto;
            dto.id = extractIdFromPath(path);
            dto.name = jsonStr(j, "name");
            dto.description = jsonStr(j, "description");
            dto.version_ = jsonStr(j, "version");
            dto.modifiedBy = jsonStr(j, "modifiedBy");

            auto result = uc.update(dto);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Document updated");
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto path = req.requestURI.to!string;
            auto id = extractIdFromPath(path);
            auto result = uc.remove(id);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["message"] = Json("Document deleted");
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
