/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.print.domain.services.print_validator;

import uim.platform.print;

// mixin(ShowModule!());

@safe:

class PrintValidator {
    static bool isValidPrintQueue(const PrintQueue queue) {
        return queue.name.length > 0;
    }

    static bool isValidPrintTask(const PrintTask task) {
        return !task.queueId.isNull && !task.documentId.isNull && task.copies >= 1;
    }

    static bool isValidPrinter(const Printer printer) {
        return printer.name.length > 0 && printer.host.length > 0;
    }

    static bool isValidPrintDocument(const PrintDocument doc) {
        return doc.fileName.length > 0 && doc.mimeType.length > 0;
    }

    static bool isValidPrintClient(const PrintClient client) {
        return client.name.length > 0 && client.hostName.length > 0;
    }
}
