/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.application.usecases.manage.import_queue_entries;

import uim.platform.transport;

// mixin(ShowModule!());

@safe:

class ManageImportQueueEntriesUseCase {
    private ImportQueueEntryRepository repo;

    this(ImportQueueEntryRepository repo) {
        this.repo = repo;
    }

    ImportQueueEntry getEntry(TenantId tenantId, ImportQueueEntryId id) {
        return repo.findById(tenantId, id);
    }

    ImportQueueEntry[] listEntries(TenantId tenantId) {
        return repo.find(tenantId);
    }

    ImportQueueEntry[] listEntriesByNode(TenantId tenantId, TransportNodeId nodeId) {
        return repo.findByNode(tenantId, nodeId);
    }

    ImportQueueEntry[] listEntriesByNodeAndStatus(TenantId tenantId, TransportNodeId nodeId, ImportStatus status) {
        return repo.findByNodeAndStatus(tenantId, nodeId, status);
    }

    ImportQueueEntry[] listEntriesByRequest(TenantId tenantId, TransportRequestId requestId) {
        return repo.findByRequest(tenantId, requestId);
    }

    CommandResult enqueue(ImportQueueEntryDTO dto) {
        ImportQueueEntry entry;
        entry.tenantId = dto.tenantId;
        entry.id = dto.entryId;
        entry.nodeId = TransportNodeId(dto.nodeId);
        entry.requestId = TransportRequestId(dto.requestId);
        entry.queuePosition = dto.queuePosition;
        entry.isSelected = dto.isSelected;
        entry.scheduledAt = dto.scheduledAt;
        entry.createdBy = dto.createdBy;
        entry.status = ImportStatus.initial;
        if (!TransportValidator.isValidQueueEntry(entry))
            return CommandResult(false, "", "Invalid queue entry: nodeId and requestId are required");

        repo.save(entry);
        return CommandResult(true, entry.id.value, "");
    }

    CommandResult updateEntryStatus(TenantId tenantId, ImportQueueEntryId id, ImportStatus status, string errorMessage = "") {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Import queue entry not found");
        existing.status = status;
        if (errorMessage.length > 0) existing.errorMessage = errorMessage;
        
        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult resetEntry(TenantId tenantId, ImportQueueEntryId id) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Import queue entry not found");
        existing.status = ImportStatus.initial;
        existing.errorMessage = "";
        existing.startedAt = 0;
        existing.completedAt = 0;
        existing.importLog = "";
        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteEntry(TenantId tenantId, ImportQueueEntryId id) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Import queue entry not found");

        repo.remove(existing);
        return CommandResult(true, existing.id.value, "");
    }
}
