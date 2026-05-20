/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.rfc.domain.entities.rfc_call;

import uim.platform.rfc;

mixin(ShowModule!());
@safe:

/// A key-value parameter value passed in or returned from an RFC call.
struct ParameterValue {
    string name;
    string value; /// Serialised as string; tables are JSON arrays

    Json toJson() const {
        return Json.emptyObject.set("name", name).set("value", value);
    }
}

/// Records a single RFC call invocation — stores input parameters, RFC type,
/// target destination, result, and all status transitions.
///
/// Covers all RFC variants described in the SAP S/4HANA connectivity docs:
///   sRFC: synchronous — result stored immediately
///   aRFC: asynchronous — status = executing until callback updates it
///   tRFC: transactional — TID assigned; exactly-once guarantee
///   qRFC: queued — TID + queue name; serialised ordering within queue
///   bgRFC: background — successor to tRFC/qRFC
struct RfcCall {
    RfcCallId        id;
    string           tenantId;
    DestinationId    destinationId;   /// Target RFC destination (SM59)
    FunctionModuleId functionModule;  /// Function module to call
    RfcType          rfcType;         /// sRFC | aRFC | tRFC | qRFC | bgRFC | ldq
    RfcStatus        status;
    TidValue         tid;             /// Transaction ID (tRFC/qRFC/bgRFC only)
    QueueName        queueName;       /// Queue name (qRFC/bgRFC only)
    ParameterValue[] importParams;    /// IMPORTING parameters sent to remote FM
    ParameterValue[] exportParams;    /// EXPORTING parameters returned
    ParameterValue[] changingParams;  /// CHANGING parameters (bidirectional)
    string           errorMessage;    /// Error detail on failure
    long             createdAt;
    long             executedAt;
    long             completedAt;

    bool isNull() const { return id.length == 0; }

    Json toJson() const {
        auto paramJson(ParameterValue[] pv) {
            auto j = Json.emptyArray;
            foreach (p; pv) j ~= p.toJson();
            return j;
        }
        return Json.emptyObject
            .set("id",              id)
            .set("tenantId",        tenantId)
            .set("destinationId",   destinationId)
            .set("functionModule",  functionModule)
            .set("rfcType",         to!string(rfcType))
            .set("status",          to!string(status))
            .set("tid",             tid)
            .set("queueName",       queueName)
            .set("importParams",    paramJson(importParams))
            .set("exportParams",    paramJson(exportParams))
            .set("changingParams",  paramJson(changingParams))
            .set("errorMessage",    errorMessage)
            .set("createdAt",       createdAt)
            .set("executedAt",      executedAt)
            .set("completedAt",     completedAt);
    }

    static RfcCall create(string tenantId, DestinationId dest, FunctionModuleId fm, RfcType rt) {
        import core.time : MonoTime;
        import std.uuid  : randomUUID;
        RfcCall c;
        c.id             = randomUUID().toString();
        c.tenantId       = tenantId;
        c.destinationId  = dest;
        c.functionModule = fm;
        c.rfcType        = rt;
        c.status         = RfcStatus.pending;
        c.createdAt      = MonoTime.currTime.ticks;
        return c;
    }
}
