/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.presentation.http.controllers.catalog;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import uim.platform.portal.application.usecases.manage_catalogs;
import uim.platform.portal.application.dto;
import uim.platform.portal.domain.entities.catalog;
import uim.platform.portal.domain.types;
import uim.platform.identity_authentication.presentation.http.json_utils;

class CatalogController {
    private ManageCatalogsUseCase useCase;

    this(ManageCatalogsUseCase useCase) {
        this.useCase = useCase;
    }

    override void registerRoutes(URLRouter router) {
        router.post("/api/v1/catalogs", &handleCreate);
        router.get("/api/v1/catalogs", &handleList);
        router.get("/api/v1/catalogs/*", &handleGet);
        router.put("/api/v1/catalogs/*", &handleUpdate);
        router.delete_("/api/v1/catalogs/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            auto createReq = CreateCatalogRequest(
                req.headers.get("X-Tenant-Id", ""),
                j.getString("title"),
                j.getString("description"),
                j.getString("providerId"),
                jsonStrArray(j, "allowedRoleIds"),
                j.getBoolean("active", true),
            );

            auto result = useCase.createCatalog(createReq);
            if (result.isSuccess()) {
                auto response = Json.emptyObject;
                response["id"] = Json(result.catalogId);
                res.writeJsonBody(response, 201);
            } else {
                writeApiError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeApiError(res, 500, "Internal server error");
        }
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.headers.get("X-Tenant-Id", "");
            auto catalogs = useCase.listCatalogs(tenantId);
            auto response = Json.emptyObject;
            response["totalResults"] = Json(cast(long)catalogs.length);
            response["resources"] = toJsonArray(catalogs);
            res.writeJsonBody(response, 200);
        } catch (Exception e) {
            writeApiError(res, 500, "Internal server error");
        }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto catalogId = extractIdFromPath(req.requestURI);
            auto catalog = useCase.getCatalog(catalogId);
            if (catalog == Catalog.init) {
                writeApiError(res, 404, "Catalog not found");
                return;
            }
            res.writeJsonBody(toJsonValue(catalog), 200);
        } catch (Exception e) {
            writeApiError(res, 500, "Internal server error");
        }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto catalogId = extractIdFromPath(req.requestURI);
            auto j = req.json;
            auto updateReq = UpdateCatalogRequest(
                catalogId,
                j.getString("title"),
                j.getString("description"),
                jsonStrArray(j, "allowedRoleIds"),
                j.getBoolean("active", true),
            );

            auto error = useCase.updateCatalog(updateReq);
            if (error.length > 0)
                writeApiError(res, 404, error);
            else
                res.writeJsonBody(Json.emptyObject, 200);
        } catch (Exception e) {
            writeApiError(res, 500, "Internal server error");
        }
    }

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto catalogId = extractIdFromPath(req.requestURI);
            auto error = useCase.deleteCatalog(catalogId);
            if (error.length > 0)
                writeApiError(res, 404, error);
            else
                res.writeJsonBody(Json.emptyObject, 204);
        } catch (Exception e) {
            writeApiError(res, 500, "Internal server error");
        }
    }
}
