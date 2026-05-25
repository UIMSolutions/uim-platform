/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.presentation.http.controllers.page;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

class PageController : PlatformController {
    private ManagePagesUseCase usecase;

    this(ManagePagesUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/build-apps/pages", &handleList);
        router.get("/api/v1/build-apps/pages/*", &handleGet);
        router.post("/api/v1/build-apps/pages", &handleCreate);
        router.put("/api/v1/build-apps/pages/*", &handleUpdate);
        router.delete_("/api/v1/build-apps/pages/*", &handleDelete);
    }

    protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId();

            auto items = usecase.listPages(tenantId);
            auto jarr = items.map!(e => e.toJson()).array.toJson;
            
            auto resp = Json.emptyObject
              .set("count", items.length)
              .set("resources", jarr)
              .set("message", "Pages retrieved");

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId();
            auto path = req.requestURI.to!string;
            auto id = PageId(extractIdFromPath(path));
            
            auto e = usecase.getPage(tenantId, id);
            if (e.isNull) { writeError(res, 404, "Page not found"); return; }
            res.writeJsonBody(e.toJson(), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId();
            auto j = req.json;

            PageDTO dto;
            dto.pageId = PageId(j.getString("id"));
            dto.tenantId = tenantId;
            dto.applicationId = ApplicationId(j.getString("applicationId"));
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.pageType = j.getString("pageType");
            dto.route = j.getString("route");
            dto.layoutConfig = j.getString("layoutConfig");
            dto.componentTree = j.getString("componentTree");
            dto.styleOverrides = j.getString("styleOverrides");
            dto.pageVariables = j.getString("pageVariables");
            dto.createdBy = UserId(j.getString("createdBy"));

            auto result = usecase.createPage(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Page created");

                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId();
            auto path = req.requestURI.to!string;
            auto j = req.json;

            PageDTO dto;
            dto.tenantId = tenantId;
            dto.pageId = PageId(extractIdFromPath(path));
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.route = j.getString("route");
            dto.layoutConfig = j.getString("layoutConfig");
            dto.componentTree = j.getString("componentTree");
            dto.updatedBy = UserId(j.getString("updatedBy"));

            auto result = usecase.updatePage(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Page updated");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId();
            auto path = req.requestURI.to!string;
            auto id = PageId(extractIdFromPath(path));

            auto result = usecase.deletePage(tenantId, id);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("message", "Page deleted");
                  
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
