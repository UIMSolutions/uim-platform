/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.presentation.cli.models.metric;

import uim.platform.redis;
mixin(ShowModule!());

@safe:

class CliMetricModel {
    Metric[] metrics;
    Metric   selected;
    bool     hasSelected;
    string   errorMessage;
    string   successMessage;

    void setMetrics(Metric[] list) { metrics = list; errorMessage = ""; }
    void setSelected(Metric m, bool found) {
        selected = m; hasSelected = found;
        errorMessage = found ? "" : "Metric not found";
    }
    void setError(string msg)   { errorMessage = msg; hasSelected = false; }
    void setSuccess(string msg) { successMessage = msg; errorMessage = ""; }
}
