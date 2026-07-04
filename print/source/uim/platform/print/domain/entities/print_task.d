/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.print.domain.entities.print_task;

import uim.platform.print;

mixin(ShowModule!());

@safe:

struct PrintTask {
    mixin TenantEntity!(PrintTaskId);

    PrintQueueId queueId;
    PrintDocumentId documentId;
    string applicationId;
    string senderApplication;
    PrintTaskStatus status = PrintTaskStatus.pending;
    int copies = 1;
    string paperFormat;
    bool colorPrint;
    bool duplexPrint;
    string tray;
    string errorMessage;
    int retryCount;
    long fetchedAt;
    long printedAt;

    Json toJson() const {
        auto j = entityToJson
            .set("queueId", queueId.value)
            .set("documentId", documentId.value)
            .set("applicationId", applicationId)
            .set("senderApplication", senderApplication)
            .set("status", status.to!string)
            .set("copies", copies)
            .set("paperFormat", paperFormat)
            .set("colorPrint", colorPrint)
            .set("duplexPrint", duplexPrint)
            .set("tray", tray)
            .set("errorMessage", errorMessage)
            .set("retryCount", retryCount)
            .set("fetchedAt", fetchedAt)
            .set("printedAt", printedAt);
        return j;
    }
}
