/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.presentation.gui.models.maintenance_window;

import uim.platform.postgres;

mixin(ShowModule!());

@safe:

class GuiMaintenanceWindowModel {
    MaintenanceWindow[] windows;
    MaintenanceWindow   selected;
    bool                hasSelected;
    string              errorMessage;
    string              successMessage;
    string              windowTitle = "PostgreSQL — Maintenance Windows";

    void delegate() @safe onChanged;

    void setWindows(MaintenanceWindow[] list) {
        windows = list; errorMessage = "";
        if (onChanged !is null) onChanged();
    }

    void setSelected(MaintenanceWindow w, bool found) {
        selected = w; hasSelected = found;
        errorMessage = found ? "" : "Maintenance window not found";
        if (onChanged !is null) onChanged();
    }

    void setError(string msg)   { errorMessage = msg; hasSelected = false; if (onChanged !is null) onChanged(); }
    void setSuccess(string msg) { successMessage = msg; errorMessage = ""; if (onChanged !is null) onChanged(); }
}
