module uim.platform.data_retention.application.usecases.manage.business_purposes;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class ManageBusinessPurposesUseCase { // TODO: UIMUseCase {
    private BusinessPurposeRepository repo;

    this(BusinessPurposeRepository repo) {
        this.repo = repo;
    }

    CommandResult create(CreateBusinessPurposeRequest req) {
        import std.uuid : randomUUID;

        if (req.name.length == 0)
            return CommandResult(false, "", "Business purpose name is required");

        BusinessPurpose bp;
        bp.id = BusinessPurposeId(randomUUID().toString());
        bp.tenantId = req.tenantId;
        bp.name = req.name;
        bp.description = req.description;
        bp.applicationGroupId = ApplicationGroupId(req.applicationGroupId);
        bp.dataSubjectRoleId = DataSubjectRoleId(req.dataSubjectRoleId);
        bp.legalEntityId = LegalEntityId(req.legalEntityId);
        bp.referenceDate = req.referenceDate;
        bp.status = BusinessPurposeStatus.inactive;
        bp.createdBy = req.createdBy;
        bp.createdAt = clockSeconds();

        repo.save(bp);
        return CommandResult(true, bp.id.value, "");
    }

    CommandResult update(string id, UpdateBusinessPurposeRequest req) {
        return update(BusinessPurposeId(id), req);
    }

    CommandResult update(BusinessPurposeId id, UpdateBusinessPurposeRequest req) {
        if (!repo.existsById(id))
            return CommandResult(false, "", "Business purpose not found");

        auto bp = repo.findById(tenantId, id);
        if (req.name.length > 0)
            bp.name = req.name;
        if (req.description.length > 0)
            bp.description = req.description;
        if (req.applicationGroupId.length > 0)
            bp.applicationGroupId = ApplicationGroupId(req.applicationGroupId);
        if (req.dataSubjectRoleId.length > 0)
            bp.dataSubjectRoleId = DataSubjectRoleId(req.dataSubjectRoleId);
        if (req.legalEntityId.length > 0)
            bp.legalEntityId = LegalEntityId(req.legalEntityId);
        if (req.referenceDate > 0)
            bp.referenceDate = req.referenceDate;
        bp.status = BusinessPurposeStatus.inactive;
        bp.updatedAt = clockSeconds();

        repo.update(bp);
        return CommandResult(true, id.value, "");
    }

    CommandResult activate(string id) {
        return activate(BusinessPurposeId(id));
    }

    CommandResult activate(BusinessPurposeId id) {
        if (!repo.existsById(id))
            return CommandResult(false, "", "Business purpose not found");

        auto bp = repo.findById(tenantId, id);
        bp.status = BusinessPurposeStatus.active;
        bp.updatedAt = clockSeconds();
        repo.update(bp);
        return CommandResult(true, id.value, "");
    }

    bool hasById(BusinessPurposeId id) {
        return repo.existsById(id);
    }

    BusinessPurpose getById(BusinessPurposeId id) {
        return repo.findById(tenantId, id);
    }

    BusinessPurpose[] list(TenantId tenantId) {
        return repo.findAll(tenantId);
    }

    BusinessPurpose[] listByApplicationGroup(TenantId tenantId, ApplicationGroupId groupId) {
        return repo.findByApplicationGroup(tenantId, groupId);
    }

    CommandResult deleteBusinessPurpose(BusinessPurposeId id) {
        if (!repo.existsById(id))
            return CommandResult(false, "", "Business purpose not found");
        auto bp = repo.findById(tenantId, id);
        if (bp.status == BusinessPurposeStatus.active)
            return CommandResult(false, "", "Cannot delete an active business purpose");
        repo.removeById(id);
        return CommandResult(true, id.value, "");
    }
}
