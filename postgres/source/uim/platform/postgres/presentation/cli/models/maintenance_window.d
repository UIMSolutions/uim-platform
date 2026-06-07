/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.presentation.cli.models.maintenance_window;

import uim.platform.postgres;

// mixin(ShowModule!());

@safe:

class CliMaintenanceWindowModel {
    MaintenanceWindow[] windows;
    MaintenanceWindow   selected;
    bool                hasSelected;
    string              errorMessage;
    string              successMessage;

    void setWindows(MaintenanceWindow[] list) { windows = list; errorMessage = ""; }

    void setSelected(MaintenanceWindow w, bool found) {
        selected    = w;
        hasSelected = found;
        errorMessage = found ? "" : "Maintenance window not found";
    }

    void setError(string msg)   { errorMessage = msg; hasSelected = false; }
    void setSuccess(string msg) { successMessage = msg; errorMessage = ""; }
}
