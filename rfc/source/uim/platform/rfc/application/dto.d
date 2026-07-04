/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.rfc.application.dto;

import uim.platform.rfc;

mixin(ShowModule!());
@safe:

// ---------------------------------------------------------------------------
// Destination DTOs
// ---------------------------------------------------------------------------

struct CreateDestinationRequest {
    string         tenantId;
    DestinationId  id;
    ConnectionType connectionType;
    string         description;
    string         host;
    ushort         port;
    SystemId       systemId;
    string         systemNumber;
    string         client;
    string         language;
    string         logonUser;
    bool           useSNC;
}

struct UpdateDestinationRequest {
    string         tenantId;
    DestinationId  id;
    string         description;
    string         host;
    ushort         port;
    string         logonUser;
    bool           useSNC;
    bool           active;
}

// ---------------------------------------------------------------------------
// FunctionModule DTOs
// ---------------------------------------------------------------------------

struct CreateFunctionModuleRequest {
    string           tenantId;
    FunctionModuleId id;
    string           functionGroup;
    string           shortText;
    string           remoteEnabled;
    RfcParameter[]   parameters;
}

struct UpdateFunctionModuleRequest {
    string           tenantId;
    FunctionModuleId id;
    string           shortText;
    string           remoteEnabled;
    RfcParameter[]   parameters;
    bool             active;
}

// ---------------------------------------------------------------------------
// RFC Call execution DTOs
// ---------------------------------------------------------------------------

struct InvokeRfcRequest {
    string           tenantId;
    DestinationId    destinationId;
    FunctionModuleId functionModule;
    RfcType          rfcType;
    string           queueName;    /// Required for qRFC; optional for bgRFC
    ParameterValue[] importParams;
    ParameterValue[] changingParams;
}

struct InvokeRfcResponse {
    bool             success;
    RfcCallId        callId;
    string           tid;          /// TID assigned for tRFC/qRFC/bgRFC (empty for sRFC/aRFC)
    RfcStatus        status;
    ParameterValue[] exportParams;
    ParameterValue[] changingParams;
    string           error;

    Json toJson() const {
        auto toArr(ParameterValue[] pv) {
            auto j = Json.emptyArray;
            foreach (p; pv) j ~= p.toJson();
            return j;
        }
        return Json.emptyObject
            .set("success",        success)
            .set("callId",         callId)
            .set("tid",            tid)
            .set("status",         to!string(status))
            .set("exportParams",   toArr(exportParams))
            .set("changingParams", toArr(changingParams))
            .set("error",          error);
    }
}

// ---------------------------------------------------------------------------
// Queue management DTO
// ---------------------------------------------------------------------------

struct ProcessQueueRequest {
    string    tenantId;
    QueueName queueName;
}

struct ProcessQueueResponse {
    bool   success;
    int    processed;
    string error;
}

// ---------------------------------------------------------------------------
// Generic command result
// ---------------------------------------------------------------------------

struct CommandResult {
    bool   success;
    string id;
    string error;
}
