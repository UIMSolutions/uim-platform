/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.presentation.web.models.service_instance;

import uim.platform.redis;
mixin(ShowModule!());

@safe:

/// Web view model for ServiceInstance — carries page-level state for web controllers.
class WebServiceInstanceModel {
    ServiceInstance[] instances;
    ServiceInstance   selected;
    bool              hasSelected;
    string            errorMessage;
    string            successMessage;
    string            pageTitle   = "Service Instances";
    int               statusCode  = 200;

    void setInstances(ServiceInstance[] list) {
        instances  = list;
        pageTitle  = "Service Instances (" ~ list.length.to!string ~ ")";
        errorMessage = "";
    }

    void setSelected(ServiceInstance inst, bool found) {
        selected    = inst;
        hasSelected = found;
        pageTitle   = found ? "Instance: " ~ inst.name : "Instance Not Found";
        statusCode  = found ? 200 : 404;
        errorMessage = found ? "" : "Service instance not found";
    }

    void setError(int code, string msg) {
        errorMessage = msg;
        statusCode   = code;
        hasSelected  = false;
    }

    void setSuccess(string msg) {
        successMessage = msg;
        errorMessage   = "";
        statusCode     = 200;
    }
}
