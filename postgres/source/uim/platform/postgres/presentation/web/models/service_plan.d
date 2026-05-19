/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.presentation.web.models.service_plan;

import uim.platform.postgres;
import std.conv : to;

mixin(ShowModule!());

@safe:

class WebServicePlanModel {
    ServicePlan[] plans;
    ServicePlan   selected;
    bool          hasSelected;
    string        errorMessage;
    string        successMessage;
    string        pageTitle  = "Service Plans";
    int           statusCode = 200;

    void setPlans(ServicePlan[] list) {
        plans        = list;
        pageTitle    = "Service Plans (" ~ list.length.to!string ~ ")";
        errorMessage = "";
    }

    void setSelected(ServicePlan p, bool found) {
        selected     = p;
        hasSelected  = found;
        pageTitle    = found ? "Plan: " ~ p.name : "Plan Not Found";
        statusCode   = found ? 200 : 404;
        errorMessage = found ? "" : "Service plan not found";
    }

    void setError(int code, string msg) { errorMessage = msg; statusCode = code; }
    void setSuccess(string msg)         { successMessage = msg; errorMessage = ""; }
}
