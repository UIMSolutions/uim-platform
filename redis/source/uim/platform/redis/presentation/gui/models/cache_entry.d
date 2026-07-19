/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.presentation.gui.models.cache_entry;

import uim.platform.redis;
mixin(ShowModule!());

@safe:

class GuiCacheEntryModel {
    CacheEntry[] entries;
    CacheEntry   selected;
    bool         hasSelected;
    string       errorMessage;
    string       successMessage;
    string       windowTitle = "Redis — Cache Entries";
    void delegate() @safe onChanged;

    void setEntries(CacheEntry[] list)              { entries = list; errorMessage = ""; if (onChanged !is null) onChanged(); }
    void setSelected(CacheEntry e, bool found)      { selected = e; hasSelected = found; errorMessage = found ? "" : "Cache entry not found"; if (onChanged !is null) onChanged(); }
    void setError(string msg)                       { errorMessage = msg; hasSelected = false; if (onChanged !is null) onChanged(); }
    void setSuccess(string msg)                     { successMessage = msg; errorMessage = ""; if (onChanged !is null) onChanged(); }
}
