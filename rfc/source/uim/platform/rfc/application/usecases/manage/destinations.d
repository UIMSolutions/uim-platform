/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.rfc.application.usecases.manage.destinations;

import uim.platform.rfc;

// mixin(ShowModule!());
@safe:

class ManageDestinationsUseCase {

    private DestinationRepository _repo;

    this(DestinationRepository repo) { _repo = repo; }

    CommandResult createDestination(CreateDestinationRequest req) {
        auto existing = _repo.findById(req.tenantId, req.id);
        if (!existing.isNull())
            return CommandResult(false, req.id, "Destination already exists: " ~ req.id);

        auto dest = Destination.create(req.id, req.tenantId, req.connectionType, req.host);
        dest.description  = req.description;
        dest.port         = req.port > 0 ? req.port : 3300;
        dest.systemId     = req.systemId;
        dest.systemNumber = req.systemNumber;
        dest.client       = req.client;
        dest.language     = req.language;
        dest.logonUser    = req.logonUser;
        dest.useSNC       = req.useSNC;

        if (!_repo.save(dest))
            return CommandResult(false, "", "Failed to save destination");
        return CommandResult(true, dest.id, "");
    }

    Destination getDestination(TenantId tenantId, DestinationId id) {
        return _repo.findById(tenantId, id);
    }

    Destination[] listDestinations(TenantId tenantId) {
        return _repo.findByTenant(tenantId);
    }

    CommandResult updateDestination(UpdateDestinationRequest req) {
        import core.time : MonoTime;
        auto dest = _repo.findById(req.tenantId, req.id);
        if (dest.isNull())
            return CommandResult(false, req.id, "Destination not found: " ~ req.id);

        dest.description = req.description;
        dest.host        = req.host;
        if (req.port > 0) dest.port = req.port;
        dest.logonUser   = req.logonUser;
        dest.useSNC      = req.useSNC;
        dest.active      = req.active;
        dest.updatedAt   = MonoTime.currTime.ticks;

        if (!_repo.update(dest))
            return CommandResult(false, dest.id, "Failed to update destination");
        return CommandResult(true, dest.id, "");
    }

    CommandResult deleteDestination(TenantId tenantId, DestinationId id) {
        auto dest = _repo.findById(tenantId, id);
        if (dest.isNull())
            return CommandResult(false, id, "Destination not found: " ~ id);
        if (!_repo.remove(tenantId, id))
            return CommandResult(false, id, "Failed to delete destination");
        return CommandResult(true, id, "");
    }

    size_t countDestinations(TenantId tenantId) {
        return _repo.countByTenant(tenantId);
    }
}
