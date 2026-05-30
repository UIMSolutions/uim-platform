/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.presentation.web.models.maintenance_window;

import uim.platform.postgres;


mixin(ShowModule!());

@safe:

class WebMaintenanceWindowModel {
    MaintenanceWindow[] windows;
    MaintenanceWindow   selected;
    bool                hasSelected;
    string              errorMessage;
    string              successMessage;
    string              pageTitle  = "Maintenance Windows";
    int                 statusCode = 200;

    void setWindows(MaintenanceWindow[] list) {
        windows      = list;
        pageTitle    = "Maintenance Windows (" ~ list.length.to!string ~ ")";
        errorMessage = "";
    }

    void setSelected(MaintenanceWindow w, bool found) {
        selected     = w;
        hasSelected  = found;
        pageTitle    = found ? "Window: " ~ w.id.value : "Window Not Found";
        statusCode   = found ? 200 : 404;
        errorMessage = found ? "" : "Maintenance window not found";
    }

    void setError(int code, string msg) { errorMessage = msg; statusCode = code; }
    void setSuccess(string msg)         { successMessage = msg; errorMessage = ""; }
}
