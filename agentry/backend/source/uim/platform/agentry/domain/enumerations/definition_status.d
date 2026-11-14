/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.domain.enumerations.definition_status;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

/// Lifecycle status of an app metadata definition
enum DefinitionStatus {
    // Initial state, not yet published
    draft,
    // Currently published and in use 
    published,
    // No longer recommended for use, but may still be available for use in certain scenarios or for backward compatibility purposes
    archived
}

DefinitionStatus toDefinitionStatus(string value) {
    mixin(EnumSwitch("DefinitionStatus", "draft"));
}

DefinitionStatus[] toDefinitionStatuses(string[] values) {
    return values.map!toDefinitionStatus.array;
}

string toString(DefinitionStatus value) {
    return value.to!string; // This will return the enum member name as a string, e.g. "draft", "published", etc
}

string[] toString(DefinitionStatus[] values) { 
    return values.map!toString.array;
}
///
unittest {
    assert("draft".toDefinitionStatus == DefinitionStatus.draft);
    assert("Published".toDefinitionStatus == DefinitionStatus.published);
    assert("ARCHIVED".toDefinitionStatus == DefinitionStatus.archived);

    assert("".toDefinitionStatus == DefinitionStatus.draft);
    assert("unknown".toDefinitionStatus == DefinitionStatus.draft);

    assert(DefinitionStatus.draft.toString == "draft");
    assert(DefinitionStatus.published.toString == "published");
    assert(DefinitionStatus.archived.toString == "archived");

    assert(["draft", "published", "archived"].toDefinitionStatuses ==
            [        DefinitionStatus.draft, DefinitionStatus.published,
                DefinitionStatus.archived
            ]);
    assert([    DefinitionStatus.draft, DefinitionStatus.published,
            DefinitionStatus.archived
        ].toString ==
        ["draft", "published", "archived"]);
}
