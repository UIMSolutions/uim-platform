/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.print.domain.repositories.printers;

import uim.platform.print;

mixin(ShowModule!());

@safe:

interface PrinterRepository : ITenantRepository!(Printer, PrinterId) {
    Printer[] findByStatus(TenantId tenantId, PrinterStatus status);
    Printer[] findByClient(TenantId tenantId, PrintClientId clientId);
    Printer[] findByProtocol(TenantId tenantId, PrinterProtocol protocol);
}
