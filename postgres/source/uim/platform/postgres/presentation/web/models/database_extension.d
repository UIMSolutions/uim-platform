/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.presentation.web.models.database_extension;

import uim.platform.postgres;


// mixin(ShowModule!());

@safe:

class WebDatabaseExtensionModel {
    DatabaseExtension[] extensions;
    DatabaseExtension   selected;
    bool                hasSelected;
    string              errorMessage;
    string              successMessage;
    string              pageTitle  = "Database Extensions";
    int                 statusCode = 200;

    void setExtensions(DatabaseExtension[] list) {
        extensions   = list;
        pageTitle    = "Database Extensions (" ~ list.length.to!string ~ ")";
        errorMessage = "";
    }

    void setSelected(DatabaseExtension e, bool found) {
        selected     = e;
        hasSelected  = found;
        pageTitle    = found ? "Extension: " ~ e.extensionName : "Extension Not Found";
        statusCode   = found ? 200 : 404;
        errorMessage = found ? "" : "Extension not found";
    }

    void setError(int code, string msg) { errorMessage = msg; statusCode = code; }
    void setSuccess(string msg)         { successMessage = msg; errorMessage = ""; }
}
