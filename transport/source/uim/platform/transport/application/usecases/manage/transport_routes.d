/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.application.usecases.manage.transport_routes;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

class ManageTransportRoutesUseCase {
    private TransportRouteRepository repo;

    this(TransportRouteRepository repo) {
        this.repo = repo;
    }

    TransportRoute getRoute(TenantId tenantId, TransportRouteId id) {
        return repo.findById(tenantId, id);
    }

    TransportRoute[] listRoutes(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    TransportRoute[] listRoutesBySourceNode(TenantId tenantId, TransportNodeId nodeId) {
        return repo.findBySourceNode(tenantId, nodeId);
    }

    TransportRoute[] listRoutesByDestinationNode(TenantId tenantId, TransportNodeId nodeId) {
        return repo.findByDestinationNode(tenantId, nodeId);
    }

    CommandResult createRoute(TransportRouteDTO dto) {
        TransportRoute route;
        route.id = dto.routeId;
        route.tenantId = dto.tenantId;
        route.name = dto.name;
        route.description = dto.description;
        route.sourceNodeId = TransportNodeId(dto.sourceNodeId);
        route.destinationNodeId = TransportNodeId(dto.destinationNodeId);
        route.isSequential = dto.isSequential;
        route.sequence = dto.sequence;
        route.createdBy = dto.createdBy;
        if (dto.status.length > 0) {
            
            try { route.status = dto.status.to!RouteStatus; } catch (Exception) {}
        }
        if (!TransportValidator.isValidRoute(route))
            return CommandResult(false, "", "Invalid route: name, source and destination node are required and must differ");
        repo.save(route);
        return CommandResult(true, route.id.value, "");
    }

    CommandResult updateRoute(TransportRouteDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.routeId);
        if (existing.isNull)
            return CommandResult(false, "", "Transport route not found");
        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        existing.isSequential = dto.isSequential;
        existing.sequence = dto.sequence;
        existing.updatedBy = dto.updatedBy;
        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult enableRoute(TenantId tenantId, TransportRouteId id) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Transport route not found");
        existing.status = RouteStatus.enabled;
        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult disableRoute(TenantId tenantId, TransportRouteId id) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Transport route not found");
        existing.status = RouteStatus.disabled;
        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteRoute(TenantId tenantId, TransportRouteId id) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Transport route not found");
        repo.remove(existing);
        return CommandResult(true, id.value, "");
    }
}
