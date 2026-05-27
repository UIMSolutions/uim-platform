/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.rfc.presentation.http.controllers.destination;

import uim.platform.rfc;

mixin(ShowModule!());
@safe:

/// HTTP controller for RFC Destinations (SM59 entries).
/// Endpoints:
///   GET    /api/v1/rfc/destinations      — list all destinations for tenant
///   POST   /api/v1/rfc/destinations      — register a new destination
///   GET    /api/v1/rfc/destinations/*    — get destination by ID
///   PUT    /api/v1/rfc/destinations/*    — update destination
///   DELETE /api/v1/rfc/destinations/*    — delete destination
class DestinationController : PlatformController {

    private ManageDestinationsUseCase _usecase;

    this(ManageDestinationsUseCase usecase) { _usecase = usecase; }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get    ("/api/v1/rfc/destinations",   &handleList);
        router.post   ("/api/v1/rfc/destinations",   &handleCreate);
        router.get    ("/api/v1/rfc/destinations/*",  &handleGet);
        router.put    ("/api/v1/rfc/destinations/*",  &handleUpdate);
        router.delete_("/api/v1/rfc/destinations/*",  &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

            auto dests    = _usecase.listDestinations(tenantId);
            auto jarr     = Json.emptyArray;
            foreach (d; dests) jarr ~= d.toJson();
            res.writeJsonBody(Json.emptyObject.set("count", cast(long) dests.length).set("items", jarr), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            CreateDestinationRequest r;
            r.tenantId       = req.getTenantId;
            r.id             = precheck.id;
            r.connectionType = cast(ConnectionType) j.getString("connectionType", "abapSystem").to!int;
            r.description    = j.getString("description", "");
            r.host           = j.getString("host", "");
            r.port           = cast(ushort) j.get("port", Json(3300)).to!long;
            r.systemId       = j.getString("systemId", "");
            r.systemNumber   = j.getString("systemNumber", "00");
            r.client         = j.getString("client", "000");
            r.language       = j.getString("language", "EN");
            r.logonUser      = j.getString("logonUser", "");
            r.useSNC         = j.get("useSNC", Json(false)).get!bool;

            auto result = _usecase.createDestination(r);
            if (result.success)
                res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Destination created"), 201);
            else
                writeError(res, 400, result.error);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id       = extractIdFromPath(req.requestURI.to!string);
            auto dest     = _usecase.getDestination(tenantId, id);
            if (dest.isNull()) { writeError(res, 404, "Destination not found"); return; }
            res.writeJsonBody(dest.toJson(), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            UpdateDestinationRequest r;
            r.tenantId   = req.getTenantId;
            r.id         = extractIdFromPath(req.requestURI.to!string);
            r.description = j.getString("description", "");
            r.host        = j.getString("host", "");
            r.port        = cast(ushort) j.get("port", Json(0)).to!long;
            r.logonUser   = j.getString("logonUser", "");
            r.useSNC      = j.get("useSNC", Json(false)).get!bool;
            r.active      = j.get("active", Json(true)).get!bool;

            auto result = _usecase.updateDestination(r);
            if (result.success)
                res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Destination updated"), 200);
            else
                writeError(res, 400, result.error);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id       = extractIdFromPath(req.requestURI.to!string);
            auto result   = _usecase.deleteDestination(tenantId, id);
            if (result.success)
                res.writeJsonBody(Json.emptyObject.set("message", "Destination deleted"), 200);
            else
                writeError(res, 404, result.error);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }
}
