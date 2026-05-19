/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.presentation.cli.models.database_extension;

import uim.platform.postgres;

mixin(ShowModule!());

@safe:

class CliDatabaseExtensionModel {
    DatabaseExtension[] extensions;
    DatabaseExtension   selected;
    bool                hasSelected;
    string              errorMessage;
    string              successMessage;

    void setExtensions(DatabaseExtension[] list) { extensions = list; errorMessage = ""; }

    void setSelected(DatabaseExtension e, bool found) {
        selected    = e;
        hasSelected = found;
        errorMessage = found ? "" : "Database extension not found";
    }

    void setError(string msg)   { errorMessage = msg; hasSelected = false; }
    void setSuccess(string msg) { successMessage = msg; errorMessage = ""; }
}
