module uim.platform.service_manager.application.usecases.manage.service_offerings;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class ManageServiceOfferingsUseCase { // TODO: UIMUseCase {
    private ServiceOfferingRepository repo;

    this(ServiceOfferingRepository repo) {
        this.repo = repo;
    }

    ServiceOffering[] listServiceOfferings(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    ServiceOffering getServiceOffering(TenantId tenantId, ServiceOfferingId id) {
        return repo.findById(tenantId, id);
    }

    CommandResult createServiceOffering(CreateServiceOfferingRequest dto) {
        ServiceOffering e;
        e.initEntity(dto.tenantId);

        e.id = ServiceOfferingId(currentTimestamp.to!string);
        e.name = dto.name;
        e.description = dto.description;
        e.catalogName = dto.catalogName;
        e.brokerId = ServiceBrokerId(dto.brokerId);
        e.tags = dto.tags;
        e.metadata = dto.metadata;
        e.createdAt = currentTimestamp;

        if (dto.name.length == 0)
            return CommandResult(false, "", "Service offering name is required");

        repo.save(e);
        return CommandResult(true, e.id.value, "");
    }

    CommandResult updateServiceOffering(UpdateServiceOfferingRequest dto) {
        auto existing = repo.findById(dto.tenantId, dto.id);
        if (existing.isNull)
            return CommandResult(false, "", "Service offering not found");

        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.catalogName.length > 0) existing.catalogName = dto.catalogName;
        if (dto.tags.length > 0) existing.tags = dto.tags;
        if (dto.metadata.length > 0) existing.metadata = dto.metadata;
        existing.updatedAt = currentTimestamp;

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteServiceOffering(TenantId tenantId, ServiceOfferingId id) {
        auto offering = repo.findById(tenantId, id);
        if (offering.isNull)
            return CommandResult(false, "", "Service offering not found");

        repo.remove(offering);
        return CommandResult(true, offering.id.value, "");
    }
}
