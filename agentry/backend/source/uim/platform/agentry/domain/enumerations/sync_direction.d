/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.domain.enumerations.sync_direction;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

/// Synchronization direction
enum SyncDirection {
    // Used for synchronization sessions that are transferring data from the mobile device to the backend system, which may include actions like uploading logs, user data, or other information collected on the device
    upload,
    // Used for synchronization sessions that are transferring data from the backend system to the mobile device, which may include actions like downloading app updates, configuration changes, or other information needed on the device
    download,
    // Used for synchronization sessions that are transferring data in both directions between the mobile device and the backend system, which may include a combination of upload and download actions as part of a comprehensive synchronization process
    bidirectional
}

SyncDirection toSyncDirection(string value) {
    mixin(EnumSwitch("SyncDirection", "bidirectional"));
}

SyncDirection[] toSyncDirections(string[] values) {
    return values.map!toSyncDirection.array;
}

string toString(SyncDirection value) {
    return value.to!string; // This will return the enum member name as a string, e.g. "upload", "download", etc
}

string[] toString(SyncDirection[] values) {
    return values.map!toString.array;
}
///
unittest {
    assert("upload".toSyncDirection == SyncDirection.upload);
    assert("Download".toSyncDirection == SyncDirection.download);
    assert("BIDIRECTIONAL".toSyncDirection == SyncDirection.bidirectional);

    assert("".toSyncDirection == SyncDirection.bidirectional);
    assert("unknown".toSyncDirection == SyncDirection.bidirectional);

    assert(SyncDirection.upload.toString == "upload");
    assert(SyncDirection.download.toString == "download");
    assert(SyncDirection.bidirectional.toString == "bidirectional");

    assert(["upload", "download", "bidirectional"].toSyncDirections ==
            [        SyncDirection.upload, SyncDirection.download,
                SyncDirection.bidirectional
            ]);
    assert(toString([    SyncDirection.upload, SyncDirection.download,
            SyncDirection.bidirectional
        ]) ==
        ["upload", "download", "bidirectional"]);
}
