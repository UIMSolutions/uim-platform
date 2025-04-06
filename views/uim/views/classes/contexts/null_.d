/****************************************************************************************************************
* Copyright: © 2017-2024 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.views.classes.contexts.null_;

import uim.views;
@safe:
 unittest {
  writeln("-----  ", __MODULE__ , "\t  -----");
}

/** Provides a context provider that does nothing.
 * This context provider simply fulfils the interface requirements that FormHelper has.
 */
class DNullFormContext : DFormContext {
    mixin(FormContextThis!("Null"));
 
    override bool isPrimaryKey(string pathToField) {
        return false;
    }
 
    override bool isCreate() {
        return false;
    }
 
    override Json val(string fieldName, Json[string] options = new Json[string]) {
        return Json(null);
    }
 
    override bool isRequired(string fieldName) {
        return false;
    }
 
    override string getRequiredMessage(string fieldName) {
        return null;
    }
 
    int getMaxLength(string fieldName) {
        return 0;
    }
 
    override string[] fieldNames() {
        return null;
    }
 
    override string type(string fieldName) {
        return null;
    }
 
    Json[string] attributes(string fieldName) {
        return null;
    }
 
    override bool hasError(string fieldName) {
        return false;
    }
 
    override  Json[string] errors(string fieldName) {
        return null;
    } 
}
mixin(FormContextCalls!("Null"));
