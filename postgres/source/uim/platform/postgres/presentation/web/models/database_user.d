/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.presentation.web.models.database_user;

import uim.platform.postgres;

mixin(ShowModule!());

@safe:

class WebDatabaseUserModel {
    DatabaseUser[] users;
    DatabaseUser   selected;
    bool           hasSelected;
    string         errorMessage;
    string         successMessage;
    string         pageTitle  = "Database Users";
    int            statusCode = 200;

    void setUsers(DatabaseUser[] list) {
        users        = list;
        pageTitle    = "Database Users (" ~ list.length.to!string ~ ")";
        errorMessage = "";
    }

    void setSelected(DatabaseUser u, bool found) {
        selected     = u;
        hasSelected  = found;
        pageTitle    = found ? "User: " ~ u.username : "User Not Found";
        statusCode   = found ? 200 : 404;
        errorMessage = found ? "" : "Database user not found";
    }

    void setError(int code, string msg) { errorMessage = msg; statusCode = code; }
    void setSuccess(string msg)         { successMessage = msg; errorMessage = ""; }
}
