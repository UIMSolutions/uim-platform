/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.domain.enumerations.connection_status;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

/// Connectivity status of a backend connection
enum ConnectionStatus {
    // Used for backend connections that are currently active and able to communicate with the mobile application management platform, which may indicate that the connection is healthy and functioning as expected
    active,
    // Used for backend connections that are currently inactive and unable to communicate with the mobile application management platform, which may indicate that the connection is down, misconfigured, or experiencing issues that need to be resolved
    inactive,
    // Used for backend connections that have encountered an error during communication or operation, which may indicate that there are issues with the connection that require troubleshooting and resolution before it can be active again
    error,
    // Used for backend connections that are currently in a testing state, which may indicate that they are being validated or verified for connectivity and functionality before being marked as active or inactive, and may require monitoring and management during the testing process
    testing
}

ConnectionStatus toConnectionStatus(string value) {
    mixin(EnumSwitch("ConnectionStatus", "inactive"));
}

ConnectionStatus[] toConnectionStatuses(string[] values) {
    return values.map!toConnectionStatus.array;
}
string toString(ConnectionStatus value) {
    return value.to!string; // This will return the enum member name as a string, e.g. "active", "inactive", etc
}
string[] toString(ConnectionStatus[] values) {
    return values.map!toString.array;
}
///
unittest {
    assert("active".toConnectionStatus == ConnectionStatus.active);
    assert("INACTIVE".toConnectionStatus == ConnectionStatus.inactive);
    assert("Error".toConnectionStatus == ConnectionStatus.error);
    assert("testing".toConnectionStatus == ConnectionStatus.testing);

    assert("unknown".toConnectionStatus == ConnectionStatus.inactive);
    assert("".toConnectionStatus == ConnectionStatus.inactive);

    assert(ConnectionStatus.active.toString == "active");
    assert(ConnectionStatus.inactive.toString == "inactive");
    assert(ConnectionStatus.error.toString == "error");
    assert(ConnectionStatus.testing.toString == "testing");

    assert(["active", "inactive", "error", "testing", "unknown"].toConnectionStatuses ==
            [        ConnectionStatus.active, ConnectionStatus.inactive,
                ConnectionStatus.error, ConnectionStatus.testing,
                ConnectionStatus.inactive
            ]);
    assert([ConnectionStatus.active, ConnectionStatus.inactive, ConnectionStatus.error,
        ConnectionStatus.testing
    ].toString ==
        ["active", "inactive", "error", "testing"]);
}
