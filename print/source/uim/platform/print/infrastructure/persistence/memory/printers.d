/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.print.infrastructure.persistence.memory.printers;

import uim.platform.print;

// mixin(ShowModule!());

@safe:

class MemoryPrinterRepository
    : TentRepository!(Printer, PrinterId), PrinterRepository {

    Printer[] findByStatus(TenantId tenantId, PrinterStatus status) {
        return findByTenant(tenantId).filter!(p => p.status == status).array;
    }

    Printer[] findByClient(TenantId tenantId, PrintClientId clientId) {
        return findByTenant(tenantId).filter!(p => p.clientId == clientId).array;
    }

    Printer[] findByProtocol(TenantId tenantId, PrinterProtocol protocol) {
        return findByTenant(tenantId).filter!(p => p.protocol == protocol).array;
    }
}
