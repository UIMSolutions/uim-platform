/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.presentation.gui.models.service_binding;

import uim.platform.redis;

// mixin(ShowModule!());

@safe:

class GuiServiceBindingModel {
    ServiceBinding[] bindings;
    ServiceBinding   selected;
    bool             hasSelected;
    string           errorMessage;
    string           successMessage;
    string           windowTitle = "Redis — Service Bindings";
    void delegate() @safe onChanged;

    void setBindings(ServiceBinding[] list)          { bindings = list; errorMessage = ""; if (onChanged !is null) onChanged(); }
    void setSelected(ServiceBinding b, bool found)   { selected = b; hasSelected = found; errorMessage = found ? "" : "Binding not found"; if (onChanged !is null) onChanged(); }
    void setError(string msg)                        { errorMessage = msg; hasSelected = false; if (onChanged !is null) onChanged(); }
    void setSuccess(string msg)                      { successMessage = msg; errorMessage = ""; if (onChanged !is null) onChanged(); }
}
