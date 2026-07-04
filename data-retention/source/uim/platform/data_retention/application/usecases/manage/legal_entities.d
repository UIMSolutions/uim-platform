module uim.platform.data_retention.application.usecases.manage.legal_entities;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class ManageLegalEntitiesUseCase { // TODO: UIMUseCase {
    private LegalEntityRepository repo;

    this(LegalEntityRepository repo) {
        this.repo = repo;
    }

    CommandResult createLegalEntity(CreateLegalEntityRequest req) {
        import std.uuid : randomUUID;

        if (req.name.length == 0)
            return CommandResult(false, "", "Legal entity name is required");

        LegalEntity le;
        le.id = LegalEntityId(randomUUID().toString());
        le.tenantId = req.tenantId;
        le.name = req.name;
        le.description = req.description;
        le.country = req.country;
        le.region = req.region;
        le.isActive = true;
        le.createdBy = req.createdBy;
        le.createdAt = clockSeconds();

        repo.save(le);
        return CommandResult(true, le.id.value, "");
    }

    CommandResult updateLegalEntity(TenantId tenantId, LegalEntityId id, UpdateLegalEntityRequest req) {
        auto le = repo.findById(tenantId, id);
        if (le.isNull)
            return CommandResult(false, "", "Legal entity not found");

        if (req.name.length > 0)
            le.name = req.name;
        if (req.description.length > 0)
            le.description = req.description;
        if (req.country.length > 0)
            le.country = req.country;
        if (req.region.length > 0)
            le.region = req.region;
        le.isActive = req.isActive;
        le.updatedAt = clockSeconds();

        repo.update(le);
        return CommandResult(true, id.value, "");
    }

    bool hasLegalEntity(TenantId tenantId, LegalEntityId id) {
        return repo.existsById(tenantId, id);
    }

    LegalEntity getLegalEntity(TenantId tenantId, LegalEntityId id) {
        return repo.findById(tenantId, id);
    }

    LegalEntity[] listLegalEntities(TenantId tenantId) {
        return repo.findAll(tenantId);
    }

    CommandResult deleteLegalEntity(TenantId tenantId, LegalEntityId id) {
        auto entity = repo.findById(tenantId, id);
        if (entity.isNull)
            return CommandResult(false, "", "Legal entity not found");

        repo.remove(entity);
        return CommandResult(true, entity.id.value, "");
    }
}
