/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.domain.enumerations.sync_status;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

/// Status of a data synchronization session
enum SyncStatus {
    // Used for synchronization sessions that are currently pending and have not yet started, which may indicate that they are waiting for a scheduled time or for certain conditions to be met before they can begin
    pending,
    // Used for synchronization sessions that are currently in progress, which may indicate that they are actively transferring data between the mobile device and the backend system
    inProgress,
    // Used for synchronization sessions that have been completed successfully, which may indicate that the data transfer was successful and the session can be closed or archived
    completed,
    // Used for synchronization sessions that have encountered an error during the synchronization process, which may indicate that the data transfer was unsuccessful and may require troubleshooting or retrying the synchronization
    failed,
    // Used for synchronization sessions that have been cancelled, which may indicate that they were intentionally stopped before completion, either by the user or by the system, and may require cleanup or rollback of any partial data transfer
    cancelled
}

SyncStatus toSyncStatus(string value) {
    mixin(EnumSwitch("SyncStatus", "pending"));
}

SyncStatus[] toSyncStatuses(string[] values) {
    return values.map!toSyncStatus.array;
}

string toString(SyncStatus value) {
    return value.to!string; // This will return the enum member name as a string, e.g. "pending", "inProgress", etc
}

string[] toString(SyncStatus[] values) {
    return values.map!toString.array;
}
///
unittest {
    assert("pending".toSyncStatus == SyncStatus.pending);
    assert("InProgress".toSyncStatus == SyncStatus.inProgress);
    assert("COMPLETED".toSyncStatus == SyncStatus.completed);
    assert("failed".toSyncStatus == SyncStatus.failed);
    assert("cancelled".toSyncStatus == SyncStatus.cancelled);

    assert("".toSyncStatus == SyncStatus.pending);
    assert("unknown".toSyncStatus == SyncStatus.pending);

    assert(SyncStatus.pending.toString == "pending");
    assert(SyncStatus.inProgress.toString == "inProgress");
    assert(SyncStatus.completed.toString == "completed");
    assert(SyncStatus.failed.toString == "failed");
    assert(SyncStatus.cancelled.toString == "cancelled");

    assert(["pending", "inProgress", "completed", "failed", "cancelled"].toSyncStatuses ==
            [        SyncStatus.pending, SyncStatus.inProgress, SyncStatus.completed,
                SyncStatus.failed, SyncStatus.cancelled
            ]);
    assert(toString([    SyncStatus.pending, SyncStatus.inProgress, SyncStatus.completed,
            SyncStatus.failed, SyncStatus.cancelled
        ]) ==
        ["pending", "inProgress", "completed", "failed", "cancelled"]);
}
