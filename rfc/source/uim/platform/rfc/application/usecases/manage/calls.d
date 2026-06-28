/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.rfc.application.usecases.manage.calls;

import uim.platform.rfc;

// mixin(ShowModule!());
@safe:

class ManageCallsUseCase {

    private RfcCallRepository _repo;

    this(RfcCallRepository repo) { _repo = repo; }

    RfcCall getCall(TenantId tenantId, RfcCallId id) {
        return _repo.find(tenantId, id);
    }

    RfcCall[] listCalls(TenantId tenantId) {
        return _repo.find(tenantId);
    }

    RfcCall[] listCallsByDestination(TenantId tenantId, DestinationId destId) {
        return _repo.findByDestination(tenantId, destId);
    }

    RfcCall[] listCallsByTid(TenantId tenantId, TidValue tid) {
        return _repo.findByTid(tenantId, tid);
    }

    RfcCall[] listCallsByStatus(TenantId tenantId, RfcStatus status) {
        return _repo.findByStatus(tenantId, status);
    }

    CommandResult deleteCall(TenantId tenantId, RfcCallId id) {
        auto call = _repo.find(tenantId, id);
        if (call.isNull())
            return CommandResult(false, id, "RFC call not found: " ~ id);
        if (!_repo.remove(tenantId, id))
            return CommandResult(false, id, "Failed to delete RFC call");
        return CommandResult(true, id, "");
    }

    size_t countCalls(TenantId tenantId) {
        return _repo.count(tenantId);
    }
}
