/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.rfc.domain.types;

import uim.platform.rfc;

// mixin(ShowModule!());

@safe:

// ---------------------------------------------------------------------------
// Strong-typed IDs
// ---------------------------------------------------------------------------
struct DestinationId {
    mixin DomainId;

    string value;

    this(string value) {
        this.value = value;
    }
} /// RFC Destination name (SM59) — up to 32 chars
struct FunctionModuleId {
    mixin DomainId;

    string value;

    this(string value) {
        this.value = value;
    }
} /// Function module name — up to 30 chars
struct RfcCallId {
    mixin DomainId;

    string value;

    this(string value) {
        this.value = value;
    }
} /// UUID of an RFC call record
struct TidValue {
    mixin DomainId;

    string value;

    this(string value) {
        this.value = value;
    }
} /// Transaction ID for tRFC/qRFC/bgRFC (24-char GUID)
struct QueueName {
    mixin DomainId;

    string value;

    this(string value) {
        this.value = value;
    }
} /// Queue name for qRFC/bgRFC — up to 24 chars
struct SystemId {
    mixin DomainId;

    string value;

    this(string value) {
        this.value = value;
    }
} /// SAP System ID (SID) — 3 chars
