/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.print.domain.entities.printer;

import uim.platform.print;

// mixin(ShowModule!());

@safe:

struct Printer {
    mixin TenantEntity!(PrinterId);

    string name;
    string description;
    PrinterStatus status = PrinterStatus.online;
    PrinterProtocol protocol = PrinterProtocol.ipp;
    string host;
    ushort port = 631;
    string queue;
    string location;
    string model;
    string vendor;
    string[] supportedFormats;
    bool colorCapable;
    bool duplexCapable;
    string[] supportedPaperFormats;
    PrintClientId clientId;

    Json toJson() const {
        auto j = entityToJson
            .set("name", name)
            .set("description", description)
            .set("status", status.to!string)
            .set("protocol", protocol.to!string)
            .set("host", host)
            .set("port", cast(int) port)
            .set("queue", queue)
            .set("location", location)
            .set("model", model)
            .set("vendor", vendor)
            .set("colorCapable", colorCapable)
            .set("duplexCapable", duplexCapable)
            .set("clientId", clientId.value);
        return j;
    }
}
