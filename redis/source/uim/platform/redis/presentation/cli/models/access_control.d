/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.presentation.cli.models.access_control;

import uim.platform.redis;
mixin(ShowModule!());

@safe:

class CliAccessControlModel {
    AccessControl[] rules;
    AccessControl   selected;
    bool            hasSelected;
    string          errorMessage;
    string          successMessage;

    void setRules(AccessControl[] list) { rules = list; errorMessage = ""; }
    void setSelected(AccessControl a, bool found) {
        selected = a; hasSelected = found;
        errorMessage = found ? "" : "Access control not found";
    }
    void setError(string msg)   { errorMessage = msg; hasSelected = false; }
    void setSuccess(string msg) { successMessage = msg; errorMessage = ""; }
}
