/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.application.usecases.manage.dead_letter_entries;

import uim.platform.service;
import uim.platform.appevents.domain.entities.dead_letter_entry;
import uim.platform.appevents.domain.repositories.dead_letter_entries;
import uim.platform.appevents.domain.valueobjects;
import uim.platform.appevents.domain.enums.dead_letter_status;
import uim.platform.appevents.application.dto;
import std.datetime.systime : Clock;

@safe:

class ManageDeadLetterEntriesUseCase {
    private DeadLetterEntryRepository repo;

    this(DeadLetterEntryRepository repo) { this.repo = repo; }

    DeadLetterEntry getDeadLetterEntry(TenantId tenantId, DeadLetterEntryId id) {
        return repo.findById(tenantId, id);
    }

    DeadLetterEntry[] listDeadLetterEntries(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    DeadLetterEntry[] listByStatus(TenantId tenantId, DeadLetterStatus status) {
        return repo.findByStatus(tenantId, status);
    }

    CommandResult createDeadLetterEntry(DeadLetterEntryDTO dto) {
        auto entry = DeadLetterEntry(dto.tenantId, dto.entryId.isNull ? DeadLetterEntryId(createId()) : dto.entryId, dto.createdBy);
        entry.originalMessageId = dto.originalMessageId;
        entry.channelId = dto.channelId;
        entry.errorMessage = dto.errorMessage;
        entry.failedAt = dto.failedAt > 0 ? dto.failedAt : Clock.currStdTime();
        entry.retryCount = 0;
        entry.status = DeadLetterStatus.pending;
        
        repo.save(entry);
        return CommandResult(true, entry.id.value, "");
    }

    CommandResult deleteDeadLetterEntry(TenantId tenantId, DeadLetterEntryId id) {
        auto entry = repo.findById(tenantId, id);
        if (entry.isNull) return CommandResult(false, "", "Dead-letter entry not found");

        repo.remove(entry);
        return CommandResult(true, entry.id.value, "");
    }
}
