/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.models.tests.data;

import uim.models;
mixin(Version!"test_uim_models");

@safe:

bool dataSetGet(Json data) {
    assert(!data.isNull, "data is null");
    /* 
    data.set("0");
    assert(data.toString == "1", "dataSetGet: data 'set string - get string' not work");

    data.set(Json(0));
    assert(data.toString == "1", "dataSetGet: data 'set json - get string' not work");

    data.set(Json(0));
    assert(data.toJson == Json(0), "dataSetGet: data 'set json - get json' not work");

    data.set("0");
    assert(data.toJson == Json(0), "dataSetGet: data 'set string - get json' not work"); */

    return true;
}