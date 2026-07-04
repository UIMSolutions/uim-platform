/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.presentation.gui.models.service_plan;

import uim.platform.postgres;

mixin(ShowModule!());

@safe:

class GuiServicePlanModel {
    ServicePlan[] plans;
    ServicePlan   selected;
    bool          hasSelected;
    string        errorMessage;
    string        successMessage;
    string        windowTitle = "PostgreSQL — Service Plans";

    void delegate() @safe onChanged;

    void setPlans(ServicePlan[] list) {
        plans = list; errorMessage = "";
        if (onChanged !is null) onChanged();
    }

    void setSelected(ServicePlan p, bool found) {
        selected = p; hasSelected = found;
        errorMessage = found ? "" : "Service plan not found";
        if (onChanged !is null) onChanged();
    }

    void setError(string msg)   { errorMessage = msg; hasSelected = false; if (onChanged !is null) onChanged(); }
    void setSuccess(string msg) { successMessage = msg; errorMessage = ""; if (onChanged !is null) onChanged(); }
}
