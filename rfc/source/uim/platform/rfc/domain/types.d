/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.rfc.domain.types;

import uim.platform.rfc;

mixin(ShowModule!());

@safe:

// ---------------------------------------------------------------------------
// Strong-typed IDs
// ---------------------------------------------------------------------------
struct DestinationId {
    mixin(IdTemplate);
} /// RFC Destination name (SM59) — up to 32 chars
struct FunctionModuleId {
    mixin(IdTemplate);
} /// Function module name — up to 30 chars
struct RfcCallId {
    mixin(IdTemplate);
} /// UUID of an RFC call record
struct TidValue {
    mixin(IdTemplate);
} /// Transaction ID for tRFC/qRFC/bgRFC (24-char GUID)
struct QueueName {
    mixin(IdTemplate);
} /// Queue name for qRFC/bgRFC — up to 24 chars
struct SystemId {
    mixin(IdTemplate);
} /// SAP System ID (SID) — 3 chars
