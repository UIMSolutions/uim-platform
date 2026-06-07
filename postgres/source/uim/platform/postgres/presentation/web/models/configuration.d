/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.presentation.web.models.configuration;

import uim.platform.postgres;


// mixin(ShowModule!());

@safe:

class WebConfigurationModel {
    Configuration[] configurations;
    Configuration   selected;
    bool            hasSelected;
    string          errorMessage;
    string          successMessage;
    string          pageTitle  = "Configurations";
    int             statusCode = 200;

    void setConfigurations(Configuration[] list) {
        configurations = list;
        pageTitle      = "Configurations (" ~ list.length.to!string ~ ")";
        errorMessage   = "";
    }

    void setSelected(Configuration c, bool found) {
        selected     = c;
        hasSelected  = found;
        pageTitle    = found ? "Configuration: " ~ c.id.value : "Configuration Not Found";
        statusCode   = found ? 200 : 404;
        errorMessage = found ? "" : "Configuration not found";
    }

    void setError(int code, string msg) { errorMessage = msg; statusCode = code; }
    void setSuccess(string msg)         { successMessage = msg; errorMessage = ""; }
}
