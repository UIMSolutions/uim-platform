/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.print.application.usecases.manage.printers;

import uim.platform.print;

mixin(ShowModule!());

@safe:

class ManagePrintersUseCase {
    private IPrinterRepository repo;

    this(IPrinterRepository repo) {
        this.repo = repo;
    }

    Printer getPrinter(TenantId tenantId, PrinterId id) {
        return repo.findById(tenantId, id);
    }

    Printer[] listPrinters(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    Printer[] listByStatus(TenantId tenantId, PrinterStatus status) {
        return repo.findByStatus(tenantId, status);
    }

    UsecaseResult createPrinter(PrinterDTO dto) {
        auto printer = Printer(dto.tenantId, dto.printerId, dto.createdBy);
        printer.name = dto.name;
        printer.description = dto.description;
        printer.host = dto.host;
        printer.port = dto.port > 0 ? dto.port : 631;
        printer.queue = dto.queue;
        printer.location = dto.location;
        printer.model = dto.model;
        printer.vendor = dto.vendor;
        printer.colorCapable = dto.colorCapable;
        printer.duplexCapable = dto.duplexCapable;
        printer.clientId = PrintClientId(dto.clientId);
        if (dto.protocol.length > 0) {
            
            try { printer.protocol = dto.protocol.to!PrinterProtocol; } catch (Exception) {}
        }

        if (!PrintValidator.isValidPrinter(printer))
            return UsecaseResult(false, "", "Invalid printer: name and host are required");

        repo.save(printer);
        return UsecaseResult(true, printer.id.value, "");
    }

    UsecaseResult updatePrinter(PrinterDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.printerId);
        if (existing.isNull)
            return UsecaseResult(false, "", "Printer not found");

        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.host.length > 0) existing.host = dto.host;
        if (dto.location.length > 0) existing.location = dto.location;
        if (dto.status.length > 0) {
            
            try { existing.status = dto.status.to!PrinterStatus; } catch (Exception) {}
        }
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;

        repo.update(existing);
        return UsecaseResult(true, existing.id.value, "");
    }

    UsecaseResult deletePrinter(TenantId tenantId, PrinterId id) {
        auto entity = repo.findById(tenantId, id);
        if (entity.isNull)
            return UsecaseResult(false, "", "Printer not found");
        repo.remove(entity);
        return UsecaseResult(true, id.value, "");
    }
}
