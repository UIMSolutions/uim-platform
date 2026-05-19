/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.presentation.web.models.service_binding;

import uim.platform.redis;

mixin(ShowModule!());

@safe:

class WebServiceBindingModel {
    ServiceBinding[] bindings;
    ServiceBinding   selected;
    bool             hasSelected;
    string           errorMessage;
    string           successMessage;
    string           pageTitle  = "Service Bindings";
    int              statusCode = 200;

    void setBindings(ServiceBinding[] list) {
        bindings  = list;
        pageTitle = "Service Bindings (" ~ list.length.to!string ~ ")";
        errorMessage = "";
    }

    void setSelected(ServiceBinding b, bool found) {
        selected = b; hasSelected = found;
        pageTitle = found ? "Binding: " ~ b.name : "Binding Not Found";
        statusCode = found ? 200 : 404;
        errorMessage = found ? "" : "Service binding not found";
    }

    void setError(int code, string msg) { errorMessage = msg; statusCode = code; hasSelected = false; }
    void setSuccess(string msg)         { successMessage = msg; errorMessage = ""; statusCode = 200; }
}
