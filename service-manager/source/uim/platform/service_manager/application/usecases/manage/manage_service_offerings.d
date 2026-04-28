module uim.platform.service_manager.application.usecases.manage.manage_service_offerings;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class ManageServiceOfferingsUseCase { // TODO: UIMUseCase {
    private ServiceOfferingRepository repo;

    this(ServiceOfferingRepository repo) {
        this.repo = repo;
    }

    ServiceOffering[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    ServiceOffering* getById(TenantId tenantId, ServiceOfferingId id) {
        return repo.findById(tenantId, id);
    }

    CommandResult create(TenantId tenantId, CreateServiceOfferingRequest dto) {
        import std.conv : to;

        ServiceOffering e;
        e.id = ServiceOfferingId(MonoTime.currTime.ticks.to!string);
        e.tenantId = tenantId;
        e.name = dto.name;
        e.description = dto.description;
        e.catalogName = dto.catalogName;
        e.brokerId = ServiceBrokerId(dto.brokerId);
        e.tags = dto.tags;
        e.metadata = dto.metadata;
        e.createdAt = MonoTime.currTime.ticks;
        e.updatedAt = e.createdAt;

        if (dto.name.length == 0)
            return CommandResult(false, "", "Service offering name is required");

        repo.save(e);
        return CommandResult(true, e.id.value, "");
    }

    CommandResult update(TenantId tenantId, ServiceOfferingId id, UpdateServiceOfferingRequest dto) {
        auto existing = repo.findById(tenantId, id);
        if (existing is null)
            return CommandResult(false, "", "Service offering not found");

        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.catalogName.length > 0) existing.catalogName = dto.catalogName;
        if (dto.tags.length > 0) existing.tags = dto.tags;
        if (dto.metadata.length > 0) existing.metadata = dto.metadata;
        existing.updatedAt = MonoTime.currTime.ticks;

        repo.update(*existing);
        return CommandResult(true, id.value, "");
    }

    CommandResult remove(TenantId tenantId, ServiceOfferingId id) {
        auto existing = repo.findById(tenantId, id);
        if (existing is null)
            return CommandResult(false, "", "Service offering not found");

        repo.removeById(tenantId, id);
        return CommandResult(true, id.value, "");
    }
}
