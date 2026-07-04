/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.rfc.domain.services.tid_manager;

import uim.platform.rfc;

mixin(ShowModule!());
@safe:

/// Manages the lifecycle of Transaction IDs (TIDs) used in tRFC / qRFC / bgRFC.
///
/// A TID identifies a Logical Unit of Work (LUW).
/// The manager ensures each TID transitions through:
///   open → executing → committed | rolledBack
/// Duplicate TIDs result in a no-op (idempotence guarantee).
struct TidManager {

    private TidRepository _repo;

    this(TidRepository repo) { _repo = repo; }

    /// Create and persist a new TID for the given destination.
    Tid createTid(TenantId tenantId, DestinationId dest) {
        auto tid = Tid.create(tenantId, dest);
        _repo.save(tid);
        return tid;
    }

    /// Check whether a TID exists and is already committed (duplicate detection).
    bool isDuplicate(TenantId tenantId, TidValue value) {
        auto tid = _repo.findById(tenantId, value);
        if (tid.isNull()) return false;
        return tid.status == LuwStatus.committed;
    }

    /// Mark TID as executing before dispatching calls.
    bool beginExecution(TenantId tenantId, TidValue value) {
        auto tid = _repo.findById(tenantId, value);
        if (tid.isNull()) return false;
        tid.status = LuwStatus.executing;
        
        tid.updatedAt = MonoTime.currTime.ticks;
        return _repo.update(tid);
    }

    /// Commit the LUW — mark TID as committed.
    bool commit(TenantId tenantId, TidValue value) {
        auto tid = _repo.findById(tenantId, value);
        if (tid.isNull()) return false;
        tid.status = LuwStatus.committed;
        
        tid.updatedAt = MonoTime.currTime.ticks;
        return _repo.update(tid);
    }

    /// Roll back the LUW — mark TID as rolled back.
    bool rollback(TenantId tenantId, TidValue value) {
        auto tid = _repo.findById(tenantId, value);
        if (tid.isNull()) return false;
        tid.status = LuwStatus.rolledBack;
        
        tid.updatedAt = MonoTime.currTime.ticks;
        return _repo.update(tid);
    }

    /// Fetch all open TIDs for a tenant (e.g. for monitoring).
    Tid[] listOpen(TenantId tenantId) {
        return _repo.findByStatus(tenantId, LuwStatus.open);
    }
}
