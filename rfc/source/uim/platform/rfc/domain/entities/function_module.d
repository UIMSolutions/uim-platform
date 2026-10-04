/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.rfc.domain.entities.function_module;

import uim.platform.rfc;

mixin(ShowModule!());
@safe:

/// A single parameter of an RFC-enabled function module.
/// Mirrors the ABAP function-module interface concept.
struct RfcParameter {
    string             name;       /// Parameter name
    ParameterDirection direction;  /// IMPORTING / EXPORTING / CHANGING / TABLES
    string             typeName;   /// ABAP data type or structure name
    string             defaultValue;
    bool               optional;
    string             description;

    Json toJson() const {
        return Json.emptyObject
            .set("name",         name)
            .set("direction",    to!string(direction))
            .set("typeName",     typeName)
            .set("defaultValue", defaultValue)
            .set("optional",     optional)
            .set("description",  description);
    }
}

/// An RFC-enabled function module definition.
/// Corresponds to an ABAP function module marked RFC-enabled in SE37.
/// Parameters mirror the ABAP function-module interface structure.
struct FunctionModule {
    FunctionModuleId id;            /// Unique function module name
    string           tenantId;
    string           functionGroup; /// FUGR (function group) this FM belongs to
    string           shortText;     /// Short description
    string           remoteEnabled; /// "ENABLED" | "NOT_ENABLED" | "CALLABLE_VIA_RFC"
    RfcParameter[]   parameters;    /// All parameters (import/export/changing/tables)
    bool             active;
    long             createdAt;
    long             updatedAt;

    bool isNull() const { return id.length == 0; }

    Json toJson() const {
        auto jParams = Json.emptyArray;
        foreach (p; parameters) jParams ~= p.toJson();
        return Json.emptyObject
            .set("id",             id)
            .set("tenantId",       tenantId)
            .set("functionGroup",  functionGroup)
            .set("shortText",      shortText)
            .set("remoteEnabled",  remoteEnabled)
            .set("parameters",     jParams)
            .set("active",         active)
            .set("createdAt",      createdAt)
            .set("updatedAt",      updatedAt);
    }

    static FunctionModule create(string id, TenantId tenantId, string functionGroup, string shortText) {
        
        FunctionModule fm;
        fm.id            = id;
        fm.tenantId      = tenantId;
        fm.functionGroup = functionGroup;
        fm.shortText     = shortText;
        fm.remoteEnabled = "ENABLED";
        fm.active        = true;
        fm.createdAt     = MonoTime.currTime.ticks;
        fm.updatedAt     = fm.createdAt;
        return fm;
    }
}
