/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.service_manager.application.usecases.manage.service_offerings;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class ManageServiceOfferingsUseCase { // TODO: UIMUseCase {
    private IServiceOfferingRepository repo;

    this(IServiceOfferingRepository repo) {
        this.repo = repo;
    }

    ServiceOffering[] listOfferings(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    ServiceOffering getOffering(TenantId tenantId, ServiceOfferingId id) {
        return repo.findById(tenantId, id);
    }

    CommandResult createOffering(CreateServiceOfferingRequest dto) {
        auto e = ServiceOffering(dto.tenantId);

        e.id = dto.offeringId.isNull ? ServiceOfferingId(randomUUID.to!string) : dto.offeringId;
        e.name = dto.name;
        e.description = dto.description;
        e.catalogName = dto.catalogName;
        e.brokerId = dto.brokerId;
        e.tags = dto.tags;
        e.metadata = dto.metadata;
        e.createdAt = currentTimestamp;

        if (dto.name.isEmpty)
            return CommandResult(false, "", "Service offering name is required");

        repo.save(e);
        return CommandResult(true, e.id.value, "");
    }

    CommandResult updateOffering(UpdateServiceOfferingRequest dto) {
        auto existing = repo.findById(dto.tenantId, dto.offeringId);
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

    CommandResult deleteOffering(TenantId tenantId, ServiceOfferingId id) {
        auto offering = repo.findById(tenantId, id);
        if (offering.isNull)
            return CommandResult(false, "", "Service offering not found");

        repo.remove(offering);
        return CommandResult(true, offering.id.value, "");
    }
}

///
unittest {
    auto repo = new ServiceOfferingRepository();
    auto usecase = new ManageServiceOfferingsUseCase(repo);
    auto tenantId = TenantId("test-tenant");

    // Test create
    CreateServiceOfferingRequest createDto;
    createDto.tenantId = tenantId;
    createDto.offeringId = ServiceOfferingId("serviceOffering-1");
    createDto.name = "Test ServiceOffering";
    auto createResult = usecase.createOffering(createDto);
    assert(createResult.success, createResult.message);

    // Test list
    auto items = usecase.listOfferings(tenantId);
    assert(items.length == 1);

    // Test get
    auto item = usecase.getOffering(tenantId, ServiceOfferingId("serviceOffering-1"));
    assert(!item.isNull);

    // Test update
    UpdateServiceOfferingRequest updateDto;
    updateDto.tenantId = tenantId;
    updateDto.offeringId = ServiceOfferingId("serviceOffering-1");
    updateDto.name = "Updated ServiceOffering";
    auto updateResult = usecase.updateOffering(updateDto);
    assert(updateResult.success, updateResult.message);

    // Test delete
    auto deleteResult = usecase.deleteOffering(tenantId, ServiceOfferingId("serviceOffering-1"));
    assert(deleteResult.success, deleteResult.message);
    assert(usecase.listOfferings(tenantId).length == 0);

}
