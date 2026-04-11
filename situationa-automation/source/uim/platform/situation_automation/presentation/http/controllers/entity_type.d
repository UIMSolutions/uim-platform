/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.presentation.http.controllers.entity_type;

// import uim.platform.situation_automation.application.usecases.manage.entity_types;
// import uim.platform.situation_automation.application.dto;

import uim.platform.situation_automation;

mixin(ShowModule!());

@safe:

class EntityTypeController : PlatformController {
    private ManageEntityTypesUseCase uc;

    this(ManageEntityTypesUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/situation-automation/entity-types", &handleList);
        router.get("/api/v1/situation-automation/entity-types/*", &handleGet);
        router.post("/api/v1/situation-automation/entity-types", &handleCreate);
        router.put("/api/v1/situation-automation/entity-types/*", &handleUpdate);
        router.delete_("/api/v1/situation-automation/entity-types/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            CreateEntityTypeRequest r;
            r.tenantId = req.getTenantId;
            r.id = j.getString("id");
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.category = j.getString("category");
            r.sourceSystem = j.getString("sourceSystem");
            r.createdBy = j.getString("createdBy");

            auto result = uc.create(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Entity type created");
                res.writeJsonBody(resp, 201);
            } ) {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            TenantId tenantId = req.getTenantId;
            auto types = uc.list(tenantId);

            auto jarr = Json.emptyArray;
            foreach (et; types) {
                auto ej = Json.emptyObject;
                ej["id"] = Json(et.id);
                ej["name"] = Json(et.name);
                ej["description"] = Json(et.description);
                ej["category"] = Json(et.category.to!string);
                ej["sourceSystem"] = Json(et.sourceSystem);
                ej["createdAt"] = Json(et.createdAt);
                jarr ~= ej;
            }

            auto resp = Json.emptyObject;
            resp["count"] = Json(types.length);
            resp["resources"] = jarr;
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            auto id = extractIdFromPath(req.requestURI.to!string);
            auto et = uc.get_(id);
            if (et.id.isEmpty) {
                writeError(res, 404, "Entity type not found");
                return;
            }

            auto resp = Json.emptyObject;
            resp["id"] = Json(et.id);
            resp["name"] = Json(et.name);
            resp["description"] = Json(et.description);
            resp["category"] = Json(et.category.to!string);
            resp["sourceSystem"] = Json(et.sourceSystem);
            resp["createdBy"] = Json(et.createdBy);
            resp["modifiedBy"] = Json(et.modifiedBy);
            resp["createdAt"] = Json(et.createdAt);
            resp["modifiedAt"] = Json(et.modifiedAt);
            resp["relatedTemplateIds"] = stringsToJsonArray(et.relatedTemplateIds);
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            auto j = req.json;
            UpdateEntityTypeRequest r;
            r.tenantId = req.getTenantId;
            r.id = extractIdFromPath(req.requestURI.to!string);
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.category = j.getString("category");
            r.modifiedBy = j.getString("modifiedBy");

            auto result = uc.update(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Entity type updated");
                res.writeJsonBody(resp, 200);
            } ) {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            auto id = extractIdFromPath(req.requestURI.to!string);
            auto result = uc.remove(id);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Entity type deleted");
                res.writeJsonBody(resp, 200);
            } ) {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
