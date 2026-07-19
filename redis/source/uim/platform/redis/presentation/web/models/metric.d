/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.presentation.web.models.metric;

import uim.platform.redis;
mixin(ShowModule!());

@safe:

class WebMetricModel {
    Metric[] metrics;
    Metric   selected;
    bool     hasSelected;
    string   errorMessage;
    string   successMessage;
    string   pageTitle  = "Metrics";
    int      statusCode = 200;

    void setMetrics(Metric[] list) { metrics = list; pageTitle = "Metrics (" ~ list.length.to!string ~ ")"; errorMessage = ""; }
    void setSelected(Metric m, bool found) {
        selected = m; hasSelected = found;
        pageTitle = found ? "Metric: " ~ m.id.value : "Metric Not Found";
        statusCode = found ? 200 : 404;
        errorMessage = found ? "" : "Metric not found";
    }
    void setError(int code, string msg) { errorMessage = msg; statusCode = code; hasSelected = false; }
    void setSuccess(string msg)         { successMessage = msg; errorMessage = ""; statusCode = 200; }
}
