/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.rfc.presentation.http.controllers.call;

import uim.platform.rfc;

mixin(ShowModule!());
@safe:

/// HTTP controller for RFC call execution and history.
/// Endpoints:
///   POST   /api/v1/rfc/calls             — invoke an RFC call (sRFC, aRFC, tRFC, qRFC, bgRFC)
///   GET    /api/v1/rfc/calls             — list all calls for tenant (with ?status=... filter)
///   GET    /api/v1/rfc/calls/*           — get call by ID
///   DELETE /api/v1/rfc/calls/*           — delete call record
class CallController : PlatformController {

    private InvokeRfcUseCase  _invokeUC;
    private ManageCallsUseCase _manageUC;

    this(InvokeRfcUseCase invokeUC, ManageCallsUseCase manageUC) {
        _invokeUC = invokeUC;
        _manageUC = manageUC;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.post   ("/api/v1/rfc/calls",   &handleInvoke);
        router.get    ("/api/v1/rfc/calls",   &handleList);
        router.get    ("/api/v1/rfc/calls/*",  &handleGet);
        router.delete_("/api/v1/rfc/calls/*",  &handleDelete);
    }

    protected void handleInvoke(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            InvokeRfcRequest r;
            r.tenantId        = req.getTenantId;
            r.destinationId   = data.getString("destinationId");
            r.functionModule  = data.getString("functionModule");
            r.rfcType         = _parseRfcType(data.getString("rfcType", "sRFC"));
            r.queueName       = data.getString("queueName", "");

            if (j.type == Json.Type.object && "importParams" in j) {
                foreach (jp; j["importParams"])
                    r.importParams ~= ParameterValue(jp.getString("name", ""), jp.getString("value", ""));
            }
            if (j.type == Json.Type.object && "changingParams" in j) {
                foreach (jp; j["changingParams"])
                    r.changingParams ~= ParameterValue(jp.getString("name", ""), jp.getString("value", ""));
            }

            auto result = _invokeUC.invoke(r);
            int httpStatus = result.success ? 200 : 400;
            res.writeJsonBody(result.toJson(), httpStatus);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

            RfcCall[] calls;

            bool hasStatus = false;
            foreach (kv; req.query.byKeyValue()) {
                if (kv.key == "status") {
                    hasStatus = true;
                    auto st   = _parseStatus(kv.value);
                    calls     = _manageUC.listCallsByStatus(tenantId, st);
                    break;
                }
            }
            if (!hasStatus) calls = _manageUC.listCalls(tenantId);

            auto jarr = Json.emptyArray;
            foreach (c; calls) jarr ~= c.toJson();
            res.writeJsonBody(Json.emptyObject.set("count", cast(long) calls.length).set("items", jarr), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto id       = extractIdFromPath(req.requestURI.to!string);
            auto call     = _manageUC.getCall(tenantId, id);
            if (call.isNull()) { writeError(res, 404, "RFC call not found"); return; }
            res.writeJsonBody(call.toJson(), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto id       = extractIdFromPath(req.requestURI.to!string);
            auto result   = _manageUC.deleteCall(tenantId, id);
            if (result.success)
                res.writeJsonBody(Json.emptyObject.set("message", "RFC call deleted"), 200);
            else
                writeError(res, 404, result.error);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

private:
    static RfcType _parseRfcType(string s) {
        import std.uni : toLower;
        switch (s.toLower()) {
            case "srfc":  return RfcType.sRFC;
            case "arfc":  return RfcType.aRFC;
            case "trfc":  return RfcType.tRFC;
            case "qrfc":  return RfcType.qRFC;
            case "bgrfc": return RfcType.bgRFC;
            case "ldq":   return RfcType.ldq;
            default:      return RfcType.sRFC;
        }
    }

    static RfcStatus _parseStatus(string s) {
        import std.uni : toLower;
        switch (s.toLower()) {
            case "pending":    return RfcStatus.pending;
            case "executing":  return RfcStatus.executing;
            case "queued":     return RfcStatus.queued;
            case "committed":  return RfcStatus.committed;
            case "rolledback": return RfcStatus.rolledBack;
            case "succeeded":  return RfcStatus.succeeded;
            case "failed":     return RfcStatus.failed;
            case "timedout":   return RfcStatus.timedOut;
            default:           return RfcStatus.pending;
        }
    }
}
