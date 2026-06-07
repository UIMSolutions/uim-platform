/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.presentation.web.models.cache_entry;

import uim.platform.redis;

// mixin(ShowModule!());

@safe:

class WebCacheEntryModel {
    CacheEntry[] entries;
    CacheEntry   selected;
    bool         hasSelected;
    string       errorMessage;
    string       successMessage;
    string       pageTitle  = "Cache Entries";
    int          statusCode = 200;

    void setEntries(CacheEntry[] list) { entries = list; pageTitle = "Cache Entries (" ~ list.length.to!string ~ ")"; errorMessage = ""; }
    void setSelected(CacheEntry e, bool found) {
        selected = e; hasSelected = found;
        pageTitle = found ? "Key: " ~ e.key : "Cache Entry Not Found";
        statusCode = found ? 200 : 404;
        errorMessage = found ? "" : "Cache entry not found";
    }
    void setError(int code, string msg) { errorMessage = msg; statusCode = code; hasSelected = false; }
    void setSuccess(string msg)         { successMessage = msg; errorMessage = ""; statusCode = 200; }
}
