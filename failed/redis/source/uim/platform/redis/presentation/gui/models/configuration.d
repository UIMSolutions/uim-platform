/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.presentation.gui.models.configuration;

import uim.platform.redis;

mixin(ShowModule!());

@safe:

class GuiConfigurationModel {
    Configuration[] configurations;
    Configuration   selected;
    bool            hasSelected;
    string          errorMessage;
    string          successMessage;
    string          windowTitle = "Redis — Configurations";
    void delegate() @safe onChanged;

    void setConfigurations(Configuration[] list)     { configurations = list; errorMessage = ""; if (onChanged !is null) onChanged(); }
    void setSelected(Configuration c, bool found)    { selected = c; hasSelected = found; errorMessage = found ? "" : "Configuration not found"; if (onChanged !is null) onChanged(); }
    void setError(string msg)                        { errorMessage = msg; hasSelected = false; if (onChanged !is null) onChanged(); }
    void setSuccess(string msg)                      { successMessage = msg; errorMessage = ""; if (onChanged !is null) onChanged(); }
}
