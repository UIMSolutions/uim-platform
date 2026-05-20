/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.responsibility.presentation.http.controllers.agent_determination;

import uim.platform.responsibility;

mixin(ShowModule!());

@safe:

class AgentDeterminationController : ManageController {
    private DetermineAgentsUseCase _uc;

    this(DetermineAgentsUseCase uc) { _uc = uc; }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.post("/api/v1/responsibility/determine", &handleDetermine);
    }

    void handleDetermine(HTTPServerRequest req, HTTPServerResponse res) {
        auto body_ = req.json;
        DetermineAgentsRequest request;
        request.tenantId   = TenantIf(body_["tenantId"].get!string);
        request.contextId  = body_["contextId"].get!string;
        request.objectType = body_["objectType"].get!string;
        request.objectId   = body_["objectId"].get!string;
        request.callerApp  = body_.gString("callerApp");

        auto result = _uc.determine(request);
        auto json = Json.emptyObject;
        json["success"]   = result.success;
        json["agents"]    = result.agents.map!(a => Json(a)).array.toJson;
        json["logId"]     = result.logId;
        json["error"]     = result.errorMessage;
        json["statusCode"] = result.success ? 200 : 422;

        res.writeBody(json.toString(), cast(int)(result.success ? HTTPStatus.ok : HTTPStatus.unprocessableEntity), "application/json");
    }
}
