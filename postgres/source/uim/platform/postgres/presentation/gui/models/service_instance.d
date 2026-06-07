/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.presentation.gui.models.service_instance;

import uim.platform.postgres;

// mixin(ShowModule!());

@safe:

class GuiServiceInstanceModel {
    ServiceInstance[] instances;
    ServiceInstance   selected;
    bool              hasSelected;
    string            errorMessage;
    string            successMessage;
    string            windowTitle = "PostgreSQL — Service Instances";

    void delegate() @safe onChanged;

    void setInstances(ServiceInstance[] list) {
        instances = list; errorMessage = "";
        if (onChanged !is null) onChanged();
    }

    void setSelected(ServiceInstance inst, bool found) {
        selected = inst; hasSelected = found;
        errorMessage = found ? "" : "Service instance not found";
        if (onChanged !is null) onChanged();
    }

    void setError(string msg)   { errorMessage = msg; hasSelected = false; if (onChanged !is null) onChanged(); }
    void setSuccess(string msg) { successMessage = msg; errorMessage = ""; if (onChanged !is null) onChanged(); }
}
