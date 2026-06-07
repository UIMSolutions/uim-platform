/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.presentation.cli.models.service_instance;

import uim.platform.postgres;

// mixin(ShowModule!());

@safe:

class CliServiceInstanceModel {
    ServiceInstance[] instances;
    ServiceInstance   selected;
    bool              hasSelected;
    string            errorMessage;
    string            successMessage;

    void setInstances(ServiceInstance[] list) { instances = list; errorMessage = ""; }

    void setSelected(ServiceInstance inst, bool found) {
        selected    = inst;
        hasSelected = found;
        errorMessage = found ? "" : "Service instance not found";
    }

    void setError(string msg)   { errorMessage = msg; hasSelected = false; }
    void setSuccess(string msg) { successMessage = msg; errorMessage = ""; }
}
