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
import std.uuid : randomUUID;
import std.conv : to;

@safe:

class ManageDeadLetterEntriesUseCase {
    private DeadLetterEntryRepository _repo;

    this(DeadLetterEntryRepository repo) {
        _repo = repo;
    }

    DeadLetterEntry getDeadLetterEntry(TenantId tenantId, DeadLetterEntryId id) {
        return _repo.findById(tenantId, id);
    }

    DeadLetterEntry[] listDeadLetterEntries(TenantId tenantId) {
        return _repo.findAll(tenantId);
    }

    DeadLetterEntry[] listByStatus(TenantId tenantId, DeadLetterStatus status) {
        return _repo.findByStatus(tenantId, status);
    }

    CommandResult createDeadLetterEntry(TenantId tenantId, DeadLetterEntryDTO dto) {
        DeadLetterEntry entry;
        entry.id = DeadLetterEntryId(randomUUID().to!string);
        entry.tenantId = tenantId;
        entry.originalMessageId = EventMessageId(dto.originalMessageId);
        entry.channelId = EventChannelId(dto.channelId);
        entry.errorMessage = dto.errorMessage;
        entry.failedAt = dto.failedAt > 0 ? dto.failedAt : Clock.currTime().toUnixTime();
        entry.retryCount = 0;
        entry.status = DeadLetterStatus.pending;
        _repo.save(tenantId, entry);
        return CommandResult(true, entry.id.value);
    }

    CommandResult deleteDeadLetterEntry(TenantId tenantId, DeadLetterEntryId id) {
        auto entry = _repo.findById(tenantId, id);
        if (entry.id.isNull) return CommandResult(false, "Dead-letter entry not found");
        _repo.remove(tenantId, id);
        return CommandResult(true, id.value);
    }
}
