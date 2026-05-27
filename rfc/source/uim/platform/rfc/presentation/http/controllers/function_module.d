/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.rfc.presentation.http.controllers.function_module;

import uim.platform.rfc;

mixin(ShowModule!());
@safe:

/// HTTP controller for RFC-enabled Function Modules (SE37 entries).
/// Endpoints:
///   GET    /api/v1/rfc/functions          — list all function modules for tenant
///   POST   /api/v1/rfc/functions          — register a function module
///   GET    /api/v1/rfc/functions/*        — get function module by ID
///   PUT    /api/v1/rfc/functions/*        — update function module
///   DELETE /api/v1/rfc/functions/*        — delete function module
class FunctionModuleController : PlatformController {

    private ManageFunctionModulesUseCase _usecase;

    this(ManageFunctionModulesUseCase usecase) { _usecase = usecase; }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get    ("/api/v1/rfc/functions",   &handleList);
        router.post   ("/api/v1/rfc/functions",   &handleCreate);
        router.get    ("/api/v1/rfc/functions/*",  &handleGet);
        router.put    ("/api/v1/rfc/functions/*",  &handleUpdate);
        router.delete_("/api/v1/rfc/functions/*",  &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

            auto fms      = _usecase.listFunctionModules(tenantId);
            auto jarr     = Json.emptyArray;
            foreach (f; fms) jarr ~= f.toJson();
            res.writeJsonBody(Json.emptyObject.set("count", cast(long) fms.length).set("items", jarr), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            CreateFunctionModuleRequest r;
            r.tenantId      = req.getTenantId;
            r.id            = precheck.id;
            r.functionGroup = j.getString("functionGroup", "");
            r.shortText     = j.getString("shortText", "");
            r.remoteEnabled = j.getString("remoteEnabled", "ENABLED");

            if (j.type == Json.Type.object && "parameters" in j) {
                foreach (jp; j["parameters"]) {
                    RfcParameter p;
                    p.name         = jp.getString("name", "");
                    p.direction    = cast(ParameterDirection) jp.getString("direction", "import_").to!int;
                    p.typeName     = jp.getString("typeName", "");
                    p.defaultValue = jp.getString("defaultValue", "");
                    p.optional     = jp.get("optional", Json(false)).get!bool;
                    p.description  = jp.getString("description", "");
                    r.parameters  ~= p;
                }
            }

            auto result = _usecase.createFunctionModule(r);
            if (result.success)
                res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Function module created"), 201);
            else
                writeError(res, 400, result.error);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto id       = extractIdFromPath(req.requestURI.to!string);
            auto fm       = _usecase.getFunctionModule(tenantId, id);
            if (fm.isNull()) { writeError(res, 404, "Function module not found"); return; }
            res.writeJsonBody(fm.toJson(), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            UpdateFunctionModuleRequest r;
            r.tenantId      = req.getTenantId;
            r.id            = extractIdFromPath(req.requestURI.to!string);
            r.shortText     = j.getString("shortText", "");
            r.remoteEnabled = j.getString("remoteEnabled", "ENABLED");
            r.active        = j.get("active", Json(true)).get!bool;

            if (j.type == Json.Type.object && "parameters" in j) {
                foreach (jp; j["parameters"]) {
                    RfcParameter p;
                    p.name         = jp.getString("name", "");
                    p.direction    = cast(ParameterDirection) jp.getString("direction", "import_").to!int;
                    p.typeName     = jp.getString("typeName", "");
                    p.defaultValue = jp.getString("defaultValue", "");
                    p.optional     = jp.get("optional", Json(false)).get!bool;
                    p.description  = jp.getString("description", "");
                    r.parameters  ~= p;
                }
            }

            auto result = _usecase.updateFunctionModule(r);
            if (result.success)
                res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Function module updated"), 200);
            else
                writeError(res, 400, result.error);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto id       = extractIdFromPath(req.requestURI.to!string);
            auto result   = _usecase.deleteFunctionModule(tenantId, id);
            if (result.success)
                res.writeJsonBody(Json.emptyObject.set("message", "Function module deleted"), 200);
            else
                writeError(res, 404, result.error);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }
}
