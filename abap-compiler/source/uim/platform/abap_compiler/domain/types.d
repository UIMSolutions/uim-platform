/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_compiler.domain.types;

import uim.platform.abap_compiler;

mixin(ShowModule!());

@safe:

/// Strongly-typed identifier for an ABAP program / report.
struct AbapProgramId {
    mixin(IdTemplate);
}

/// ABAP program / report identifier (up to 40 chars, SAP convention)
struct AbapClassId {
    mixin(IdTemplate);
}

/// ABAP interface identifier (up to 40 chars, SAP convention)
struct AbapInterfaceId {
    mixin(IdTemplate);
}

/// Function-group (fugr) identifier (up to 20 chars, SAP convention)
struct AbapFunctionGroupId {
    mixin(IdTemplate);
}

/// Function-module identifier (up to 30 chars, SAP convention)
struct AbapFunctionModuleId {
    mixin(IdTemplate);
}

/// ABAP Dictionary data identifier (up to 30 chars, SAP convention)
struct AbapDataTypeId {
    mixin(IdTemplate);
}

/// ABAP Dictionary table identifier (up to 30 chars, SAP convention)
struct AbapTableId {
    mixin(IdTemplate);
}

/// ABAP Dictionary view identifier (up to 30 chars, SAP convention)
struct AbapViewId {
    mixin(IdTemplate);
}

/// ABAP Dictionary domain identifier (up to 20 chars, SAP convention)
struct AbapDomainId {
    mixin(IdTemplate);
}

/// ABAP Dictionary search help identifier (up to 30 chars, SAP convention)
struct AbapSearchHelpId {
    mixin(IdTemplate);
}

/// ABAP Dictionary lock object identifier (up to 20 chars, SAP convention)
struct AbapLockObjectId {
    mixin(IdTemplate);
}

/// ABAP Dictionary type pool identifier (up to 20 chars, SAP convention)
struct AbapTypePoolId {
    mixin(IdTemplate);
}

/// ABAP Dictionary package identifier (up to 20 chars, SAP convention)
struct AbapPackageId {
    mixin(IdTemplate);
}

/// ABAP Dictionary transport request identifier (up to 10 chars, SAP convention)
struct AbapTransportRequestId {
    mixin(IdTemplate);
}

/// ABAP Dictionary transport layer identifier (up to 3 chars, SAP convention)
struct AbapTransportLayerId {
    mixin(IdTemplate);
}

/// ABAP Dictionary transport target system identifier (up to 10 chars, SAP convention)
struct AbapTransportTargetSystemId {
    mixin(IdTemplate);
}

/// ABAP Dictionary transport target client identifier (up to 3 chars, SAP convention)
struct AbapTransportTargetClientId {
    mixin(IdTemplate);
}

/// ABAP Dictionary transport target package identifier (up to 20 chars, SAP convention)
struct AbapTransportTargetPackageId {
    mixin(IdTemplate);
}

/// ABAP Dictionary transport target object identifier (up to 30 chars, SAP convention)
struct AbapTransportTargetObjectId {
    mixin(IdTemplate);
}

struct ApplicationJobId {
    mixin(IdTemplate);
}

/// Compilation job identifier (UUID)
struct CompilationJobId {
    mixin(IdTemplate);
}

/// Token identifier (UUID)
struct TokenId {
    mixin(IdTemplate);

    this(long value) {
        this.value = value.to!string;
    }
}
