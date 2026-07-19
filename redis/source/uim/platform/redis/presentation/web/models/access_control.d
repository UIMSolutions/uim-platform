/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.presentation.web.models.access_control;

import uim.platform.redis;
mixin(ShowModule!());

@safe:

class WebAccessControlModel {
    AccessControl[] rules;
    AccessControl   selected;
    bool            hasSelected;
    string          errorMessage;
    string          successMessage;
    string          pageTitle  = "Access Control Rules";
    int             statusCode = 200;

    void setRules(AccessControl[] list) { rules = list; pageTitle = "Access Rules (" ~ list.length.to!string ~ ")"; errorMessage = ""; }
    void setSelected(AccessControl a, bool found) {
        selected = a; hasSelected = found;
        pageTitle = found ? "Rule: " ~ a.cidrBlock : "Rule Not Found";
        statusCode = found ? 200 : 404;
        errorMessage = found ? "" : "Access control not found";
    }
    void setError(int code, string msg) { errorMessage = msg; statusCode = code; hasSelected = false; }
    void setSuccess(string msg)         { successMessage = msg; errorMessage = ""; statusCode = 200; }
}
