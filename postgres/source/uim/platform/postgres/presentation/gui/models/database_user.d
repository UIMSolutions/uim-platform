/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.presentation.gui.models.database_user;

import uim.platform.postgres;

// mixin(ShowModule!());

@safe:

class GuiDatabaseUserModel {
    DatabaseUser[] users;
    DatabaseUser   selected;
    bool           hasSelected;
    string         errorMessage;
    string         successMessage;
    string         windowTitle = "PostgreSQL — Database Users";

    void delegate() @safe onChanged;

    void setUsers(DatabaseUser[] list) {
        users = list; errorMessage = "";
        if (onChanged !is null) onChanged();
    }

    void setSelected(DatabaseUser u, bool found) {
        selected = u; hasSelected = found;
        errorMessage = found ? "" : "Database user not found";
        if (onChanged !is null) onChanged();
    }

    void setError(string msg)   { errorMessage = msg; hasSelected = false; if (onChanged !is null) onChanged(); }
    void setSuccess(string msg) { successMessage = msg; errorMessage = ""; if (onChanged !is null) onChanged(); }
}
