/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.presentation.cli.models.service_plan;

import uim.platform.redis;

mixin(ShowModule!());

@safe:

class CliServicePlanModel {
    ServicePlan[] plans;
    ServicePlan   selected;
    bool          hasSelected;
    string        errorMessage;
    string        successMessage;

    void setPlans(ServicePlan[] list)    { plans = list; errorMessage = ""; }
    void setSelected(ServicePlan p, bool found) {
        selected = p; hasSelected = found;
        errorMessage = found ? "" : "Service plan not found";
    }
    void setError(string msg)   { errorMessage = msg; hasSelected = false; }
    void setSuccess(string msg) { successMessage = msg; errorMessage = ""; }
}
