/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.domain.enumerations.app_status;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

/// Lifecycle status of a registered mobile application
enum AppStatus : string {
    // Used for app registrations that are currently in development and have not yet been published, which may indicate that they are not yet available for deployment or use by end users
    draft = "draft",
    // Used for app registrations that are currently published and available for deployment or use by end users, which may indicate that they have passed any necessary testing and validation processes and are ready for production use
    active = "active",
    // Used for app registrations that are no longer recommended for use, which may indicate that they have been superseded by newer versions or have known issues that make them less desirable for deployment or use by end users, but may still be available for use in certain scenarios or for backward compatibility purposes
    deprecated_ = "deprecated",
    // Used for app registrations that are no longer active and have been withdrawn from availability, which may indicate that they have been removed from the system and are no longer accessible for deployment or use by end users, and may require cleanup or archival of any associated resources or data
    archived = "archived"
}

AppStatus toAppStatus(string value) {
    switch(value.toLower) {
    case "draft":
            return AppStatus.draft;
        case "active":
            return AppStatus.active;
        case "deprecated":
            return AppStatus.deprecated_;
        case "archived":
            return AppStatus.archived;
        default:
            return AppStatus.draft; // Default to draft if the input string does not match any known status
    }
}

AppStatus[] toAppStatuses(string[] values) {
    return values.map!toAppStatus.array;
}

string toString(AppStatus value) {
    return cast(string)value; // This will return the enum member name as a string, e.g. "draft", "active", etc
}

string[] toString(AppStatus[] values) {
    return values.map!toString.array;
}
///
unittest {
    assert("draft".toAppStatus == AppStatus.draft);
    assert("Active".toAppStatus == AppStatus.active);
    assert("DEPRECATED".toAppStatus == AppStatus.deprecated_);
    assert("archived".toAppStatus == AppStatus.archived);

    assert("".toAppStatus == AppStatus.draft);
    assert("unknown".toAppStatus == AppStatus.draft); // Default case

    assert(AppStatus.draft.toString == "draft");
    assert(AppStatus.active.toString == "active");
    assert(AppStatus.deprecated_.toString == "deprecated");
    assert(AppStatus.archived.toString == "archived");

    assert(["draft", "active", "deprecated", "archived"].toAppStatuses ==
            [        AppStatus.draft, AppStatus.active, AppStatus.deprecated_,
                AppStatus.archived
            ]);
    assert([    AppStatus.draft, AppStatus.active, AppStatus.deprecated_,
            AppStatus.archived
        ].toString ==
        ["draft", "active", "deprecated", "archived"]);
}
