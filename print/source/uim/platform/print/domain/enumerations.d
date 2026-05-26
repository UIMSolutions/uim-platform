/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.print.domain.enumerations;

@safe:

/// Operational status of a print queue
enum PrintQueueStatus {
    active,
    paused,
    inactive
}

/// Processing status of a print task
enum PrintTaskStatus {
    pending,
    fetched,
    processing,
    printed,
    failed,
    cancelled
}

/// Availability status of a printer
enum PrinterStatus {
    online,
    offline,
    error,
    unknown
}

/// Protocol used to communicate with the printer
enum PrinterProtocol {
    ipp,
    lpd,
    usb,
    virtual_,
    cups
}

/// Document format / MIME type group
enum DocumentFormat {
    pdf,
    postscript,
    zpl,
    pcl,
    png,
    jpeg,
    tiff,
    html,
    raw
}

/// Connectivity status of a print client agent
enum PrintClientStatus {
    registered,
    active,
    inactive,
    error
}

/// Persistence backend selection
enum PersistenceBackend {
    memory,
    file_,
    mongodb
}
