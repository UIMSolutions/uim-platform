/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.domain.services.situation_evaluator;

import uim.platform.situation_automation;

mixin(ShowModule!());

@safe:

struct SituationEvaluator {
    static string validate(string id, string name) {
        if (id.length == 0)
            return "ID is required";
        if (name.length == 0)
            return "Name is required";
        if (name.length > 256)
            return "Name must be 256 characters or fewer";
        return "";
    }
}
