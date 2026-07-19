/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.presentation.gui.models.access_control;

import uim.platform.redis;
mixin(ShowModule!());

@safe:

class GuiAccessControlModel {
    AccessControl[] rules;
    AccessControl   selected;
    bool            hasSelected;
    string          errorMessage;
    string          successMessage;
    string          windowTitle = "Redis — Access Control Rules";
    void delegate() @safe onChanged;

    void setRules(AccessControl[] list)            { rules = list; errorMessage = ""; if (onChanged !is null) onChanged(); }
    void setSelected(AccessControl a, bool found)  { selected = a; hasSelected = found; errorMessage = found ? "" : "Rule not found"; if (onChanged !is null) onChanged(); }
    void setError(string msg)                      { errorMessage = msg; hasSelected = false; if (onChanged !is null) onChanged(); }
    void setSuccess(string msg)                    { successMessage = msg; errorMessage = ""; if (onChanged !is null) onChanged(); }
}
