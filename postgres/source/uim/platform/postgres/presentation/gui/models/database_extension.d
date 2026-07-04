/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.presentation.gui.models.database_extension;

import uim.platform.postgres;

mixin(ShowModule!());

@safe:

class GuiDatabaseExtensionModel {
    DatabaseExtension[] extensions;
    DatabaseExtension   selected;
    bool                hasSelected;
    string              errorMessage;
    string              successMessage;
    string              windowTitle = "PostgreSQL — Database Extensions";

    void delegate() @safe onChanged;

    void setExtensions(DatabaseExtension[] list) {
        extensions = list; errorMessage = "";
        if (onChanged !is null) onChanged();
    }

    void setSelected(DatabaseExtension e, bool found) {
        selected = e; hasSelected = found;
        errorMessage = found ? "" : "Extension not found";
        if (onChanged !is null) onChanged();
    }

    void setError(string msg)   { errorMessage = msg; hasSelected = false; if (onChanged !is null) onChanged(); }
    void setSuccess(string msg) { successMessage = msg; errorMessage = ""; if (onChanged !is null) onChanged(); }
}
