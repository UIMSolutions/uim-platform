/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.domain.enumerations.app_version_status;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

/// Published release status of an app version
enum AppVersionStatus : string {
    // Used for app versions that are currently in development and have not yet been released, which may indicate that they are not yet available for deployment or use by end users
    pending = "pending",
    // Used for app versions that are currently published and available for deployment or use by end users, which may indicate that they have passed any necessary testing and validation processes and are ready for production use
    published = "published",
    // Used for app versions that are no longer recommended for use, which may indicate that they have been superseded by newer versions or have known issues that make them less desirable for deployment or use by end users, but may still be available for use in certain scenarios or for backward compatibility purposes
    deprecated_ = "deprecated",
    // Used for app versions that are no longer active and have been withdrawn from availability, which may indicate that they have been removed from the system and are no longer accessible for deployment or use by end users, and may require cleanup or archival of any associated resources or data
    withdrawn = "withdrawn"
}

AppVersionStatus toAppVersionStatus(string status) {
    switch (status.toLower) {
    case "pending":
        return AppVersionStatus.pending;
    case "published":
        return AppVersionStatus.published;
    case "deprecated":
        return AppVersionStatus.deprecated_;
    case "withdrawn":
        return AppVersionStatus.withdrawn;
    default:
        return AppVersionStatus.pending; // Default to pending if the input string does not match any known status
    }
}

AppVersionStatus[] toAppVersionStatuses(string[] statuses) {
    return statuses.map!toAppVersionStatus.array;
}
string toString(AppVersionStatus value) {
    return cast(string)value; // This will return the enum member name as a string, e.g. "pending", "published", etc
}
string[] toString(AppVersionStatus[] values) {
    return values.map!toString.array;
}
///
unittest {
    assert("pending".toAppVersionStatus == AppVersionStatus.pending);
    assert("Published".toAppVersionStatus == AppVersionStatus.published);
    assert("DEPRECATED".toAppVersionStatus == AppVersionStatus.deprecated_);
    assert("withdrawn".toAppVersionStatus == AppVersionStatus.withdrawn);

    assert("".toAppVersionStatus == AppVersionStatus.pending);
    assert("unknown".toAppVersionStatus == AppVersionStatus.pending);

    assert(AppVersionStatus.pending.toString == "pending");
    assert(AppVersionStatus.published.toString == "published");
    assert(AppVersionStatus.deprecated_.toString == "deprecated");
    assert(AppVersionStatus.withdrawn.toString == "withdrawn");

    assert(["pending", "published", "deprecated", "withdrawn"].map!(toAppVersionStatus)
            .array ==
            [        AppVersionStatus.pending, AppVersionStatus.published,
                AppVersionStatus.deprecated_, AppVersionStatus.withdrawn
            ]);
    assert([    AppVersionStatus.pending, AppVersionStatus.published,
            AppVersionStatus.deprecated_, AppVersionStatus.withdrawn
        ].toString ==
        ["pending", "published", "deprecated", "withdrawn"]);
}
