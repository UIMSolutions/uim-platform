/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.rfc.presentation.http.controllers.destination;

import uim.platform.rfc;

// mixin(ShowModule!());
@safe:

/// HTTP controller for RFC Destinations (SM59 entries).
/// Endpoints:
///   GET    /api/v1/rfc/destinations      — list all destinations for tenant
///   POST   /api/v1/rfc/destinations      — register a new destination
///   GET    /api/v1/rfc/destinations/*    — get destination by ID
///   PUT    /api/v1/rfc/destinations/*    — update destination
///   DELETE /api/v1/rfc/destinations/*    — delete destination
class DestinationController : HttpController {

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

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
            auto data = precheck.data;
            CreateDestinationRequest r;
            r.tenantId       = tenantId;
            r.id             = precheck.id;
            r.connectionType = cast(ConnectionType) data.getString("connectionType", "abapSystem").to!int;
            r.description    = data.getString("description", "");
            r.host           = data.getString("host", "");
            r.port           = cast(ushort) j.get("port", Json(3300)).to!long;
            r.systemId       = data.getString("systemId", "");
            r.systemNumber   = data.getString("systemNumber", "00");
            r.client         = data.getString("client", "000");
            r.language       = data.getString("language", "EN");
            r.logonUser      = data.getString("logonUser", "");
            r.useSNC         = j.get("useSNC", Json(false)).get!bool;

            auto result = _usecase.createDestination(r);
            if (result.success)
                res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Destination created"), 201);
            else
                writeError(res, 400, result.error);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
            auto id       = extractIdFromPath(req.requestURI.to!string);
            auto dest     = _usecase.getDestination(tenantId, id);
            if (dest.isNull()) { writeError(res, 404, "Destination not found"); return; }
            res.writeJsonBody(dest.toJson(), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
            auto data = precheck.data;
            UpdateDestinationRequest r;
            r.tenantId   = tenantId;
            r.id         = extractIdFromPath(req.requestURI.to!string);
            r.description = data.getString("description", "");
            r.host        = data.getString("host", "");
            r.port        = cast(ushort) j.get("port", Json(0)).to!long;
            r.logonUser   = data.getString("logonUser", "");
            r.useSNC      = j.get("useSNC", Json(false)).get!bool;
            r.active      = j.get("active", Json(true)).get!bool;

            auto result = _usecase.updateDestination(r);
            if (result.success)
                res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Destination updated"), 200);
            else
                writeError(res, 400, result.error);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
            auto id       = extractIdFromPath(req.requestURI.to!string);
            auto result   = _usecase.deleteDestination(tenantId, id);
            if (result.success)
                res.writeJsonBody(Json.emptyObject.set("message", "Destination deleted"), 200);
            else
                writeError(res, 404, result.error);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }
}
