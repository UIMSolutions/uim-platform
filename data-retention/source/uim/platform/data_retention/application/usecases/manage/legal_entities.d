module uim.platform.data_retention.application.usecases.manage.legal_entities;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class ManageLegalEntitiesUseCase { // TODO: UIMUseCase {
    private LegalEntityRepository repo;

    this(LegalEntityRepository repo) { this.repo = repo; }

    CommandResult create(CreateLegalEntityRequest req) {
        import std.uuid : randomUUID;
        if (req.name.length == 0) return CommandResult(false, "", "Legal entity name is required");

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

    CommandResult update(string id, UpdateLegalEntityRequest req) { return update(LegalEntityId(id), req); }

    CommandResult update(LegalEntityId id, UpdateLegalEntityRequest req) {
        if (!repo.existsById(id)) return CommandResult(false, "", "Legal entity not found");

        auto le = repo.findById(id);
        if (req.name.length > 0) le.name = req.name;
        if (req.description.length > 0) le.description = req.description;
        if (req.country.length > 0) le.country = req.country;
        if (req.region.length > 0) le.region = req.region;
        le.isActive = req.isActive;
        le.updatedAt = clockSeconds();

        repo.update(le);
        return CommandResult(true, id.value, "");
    }

    bool hasById(string id) { return hasById(LegalEntityId(id)); }
    bool hasById(LegalEntityId id) { return repo.existsById(id); }
    LegalEntity getById(string id) { return getById(LegalEntityId(id)); }
    LegalEntity getById(LegalEntityId id) { return repo.findById(id); }
    LegalEntity[] list(TenantId tenantId) { return list(TenantId(tenantId)); }
    LegalEntity[] list(TenantId tenantId) { return repo.findAll(tenantId); }
    CommandResult remove(string id) { return remove(LegalEntityId(id)); }
    CommandResult remove(LegalEntityId id) { repo.removeById(id); return CommandResult(true, id.value, ""); }
}
