/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_compiler.domain.types;

import uim.platform.abap_compiler;

mixin(ShowModule!());

@safe:

// ---------------------------------------------------------------------------
// Strong-typed IDs
// ---------------------------------------------------------------------------
struct ProgramId {
    mixin DomainId;

    string value;
    this(string value) {
        this.value = value;
    }
}  /// ABAP program / report name (up to 40 chars, SAP convention)
struct ClassId {
    mixin DomainId;

    string value;
    this(string value) {
        this.value = value;
    }
}  /// ABAP class name (up to 30 chars)
struct InterfaceId {
    mixin DomainId;

    string value;
    this(string value) {
        this.value = value;
    }
}  /// ABAP interface name
struct FunctionGroupId {
    mixin DomainId;

    string value;
    this(string value) {
        this.value = value;
    }
}  /// Function-group (fugr) name
struct FunctionModuleId {
    mixin DomainId;

    string value;
    this(string value) {
        this.value = value;
    }
} /// Function-module name
struct DataTypeId {
    mixin DomainId;

    string value;
    this(string value) {
        this.value = value;
    }
}  /// ABAP Dictionary data type name
struct CompilationJobId {
    mixin DomainId;

    string value;
    this(string value) {
        this.value = value;
    }
} /// Internal job UUID for a compilation run
struct TokenId {
    mixin DomainId;

    string value;
    this(string value) {
        this.value = value;
    }
}  /// Ordinal position of a token in a source
