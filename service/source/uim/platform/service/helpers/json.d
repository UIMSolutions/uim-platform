/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.service.helpers.json;

import uim.platform.service;

mixin(ShowModule!());

@safe:

bool hasError(Json data) {
    if (data.isNull || !data.hasKey("status")) {
        return true;
    }
    auto status = data.getString("status");
    return status == "error";
}
///
unittest {
    auto errorJson = Json.emptyObject.set("status", "error").set("error", "Something went wrong");
    assert(hasError(errorJson) == true);

    auto successJson = Json.emptyObject.set("status", "success").set("data", "All good");
    assert(hasError(successJson) == false);

    auto invalidJson = Json.emptyObject.set("message", "No status field");
    assert(hasError(invalidJson) == true);
}

Json errorResponse(string message = "Internal Server Error", int code = 500) {
    return Json.emptyObject
        .set("status", "error")
        .set("error", message)
        .set("statusCode", code);
}

