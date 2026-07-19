/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.presentation.cli.models.service_binding;

import uim.platform.redis;
mixin(ShowModule!());

@safe:

class CliServiceBindingModel {
    ServiceBinding[] bindings;
    ServiceBinding   selected;
    bool             hasSelected;
    string           errorMessage;
    string           successMessage;

    void setBindings(ServiceBinding[] list) {
        bindings = list;
        errorMessage = "";
    }

    void setSelected(ServiceBinding b, bool found) {
        selected    = b;
        hasSelected = found;
        errorMessage = found ? "" : "Service binding not found";
    }

    void setError(string msg)   { errorMessage = msg; hasSelected = false; }
    void setSuccess(string msg) { successMessage = msg; errorMessage = ""; }
}
