/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.domain.enumerations.device_status;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

/// Enrollment and activity status of a mobile device
enum DeviceStatus {
    // Used for devices that have been enrolled in the system but may not yet be active or in use, which may require additional steps to complete the enrollment process and activate the device
    enrolled,
    // Used for devices that are currently active and in use, allowing them to receive app deployments, updates, and other management actions
    active,
    // Used for devices that have been suspended, which may indicate a temporary issue or policy violation
    suspended,
    // Used for devices that have been removed from the system, which may indicate that they are no longer in use and have been deleted from the system
    removed
}

DeviceStatus toDeviceStatus(string value) {
    mixin(EnumSwitch("DeviceStatus", "enrolled"));
}

DeviceStatus[] toDeviceStatuses(string[] values) {
    return values.map!toDeviceStatus.array;
}
string toString(DeviceStatus value) {
    return value.to!string; // This will return the enum member name as a string, e.g. "enrolled", "active", etc
}
string[] toString(DeviceStatus[] values) {
    return values.map!toString.array;
}
///
unittest {
    assert("enrolled".toDeviceStatus == DeviceStatus.enrolled);
    assert("Active".toDeviceStatus == DeviceStatus.active);
    assert("SUSPENDED".toDeviceStatus == DeviceStatus.suspended);
    assert("removed".toDeviceStatus == DeviceStatus.removed);

    assert("".toDeviceStatus == DeviceStatus.enrolled);
    assert("unknown".toDeviceStatus == DeviceStatus.enrolled);

    assert(DeviceStatus.enrolled.toString == "enrolled");
    assert(DeviceStatus.active.toString == "active");
    assert(DeviceStatus.suspended.toString == "suspended");
    assert(DeviceStatus.removed.toString == "removed");

    assert(["enrolled", "active", "suspended", "removed"].toDeviceStatuses ==
            [        DeviceStatus.enrolled, DeviceStatus.active, DeviceStatus.suspended,
                DeviceStatus.removed
            ]);
    assert(toString([    DeviceStatus.enrolled, DeviceStatus.active, DeviceStatus.suspended,
            DeviceStatus.removed
        ]) ==
        ["enrolled", "active", "suspended", "removed"]);
}
