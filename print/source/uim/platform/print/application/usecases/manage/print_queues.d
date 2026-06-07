/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.print.application.usecases.manage.print_queues;

import uim.platform.print;

// mixin(ShowModule!());

@safe:

class ManagePrintQueuesUseCase {
    private PrintQueueRepository repo;

    this(PrintQueueRepository repo) {
        this.repo = repo;
    }

    PrintQueue getPrintQueue(TenantId tenantId, PrintQueueId id) {
        return repo.findById(tenantId, id);
    }

    PrintQueue[] listPrintQueues(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    PrintQueue[] listByStatus(TenantId tenantId, PrintQueueStatus status) {
        return repo.findByStatus(tenantId, status);
    }

    CommandResult createPrintQueue(PrintQueueDTO dto) {
        PrintQueue queue;
        queue.initEntity(dto.tenantId, dto.createdBy);
        queue.id = dto.queueId;
        queue.name = dto.name;
        queue.description = dto.description;
        queue.printerId = PrinterId(dto.printerId);
        queue.location = dto.location;
        queue.costCenter = dto.costCenter;
        queue.isDefault = dto.isDefault;
        queue.maxRetries = dto.maxRetries > 0 ? dto.maxRetries : 3;
        queue.retentionDays = dto.retentionDays > 0 ? dto.retentionDays : 7;

        if (!PrintValidator.isValidPrintQueue(queue))
            return CommandResult(false, "", "Invalid print queue: name is required");

        repo.save(queue);
        return CommandResult(true, queue.id.value, "");
    }

    CommandResult updatePrintQueue(PrintQueueDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.queueId);
        if (existing.isNull)
            return CommandResult(false, "", "Print queue not found");

        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.location.length > 0) existing.location = dto.location;
        if (dto.costCenter.length > 0) existing.costCenter = dto.costCenter;
        if (dto.status.length > 0) {
            
            try { existing.status = dto.status.to!PrintQueueStatus; } catch (Exception) {}
        }
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deletePrintQueue(TenantId tenantId, PrintQueueId id) {
        auto entity = repo.findById(tenantId, id);
        if (entity.isNull)
            return CommandResult(false, "", "Print queue not found");
        repo.remove(entity);
        return CommandResult(true, id.value, "");
    }
}
