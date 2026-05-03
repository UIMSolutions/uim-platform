module uim.platform.data_retention.application.usecases.manage.business_purposes;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class ManageBusinessPurposesUseCase { // TODO: UIMUseCase {
    private BusinessPurposeRepository repo;

    this(BusinessPurposeRepository repo) { this.repo = repo; }

    CommandResult create(CreateBusinessPurposeRequest req) {
        import std.uuid : randomUUID;
        if (req.name.length == 0) return CommandResult(false, "", "Business purpose name is required");

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

    CommandResult update(string id, UpdateBusinessPurposeRequest req) { return update(BusinessPurposeId(id), req); }

    CommandResult update(BusinessPurposeId id, UpdateBusinessPurposeRequest req) {
        if (!repo.existsById(id)) return CommandResult(false, "", "Business purpose not found");

        auto bp = repo.findById(id);
        if (req.name.length > 0) bp.name = req.name;
        if (req.description.length > 0) bp.description = req.description;
        if (req.applicationGroupId.length > 0) bp.applicationGroupId = ApplicationGroupId(req.applicationGroupId);
        if (req.dataSubjectRoleId.length > 0) bp.dataSubjectRoleId = DataSubjectRoleId(req.dataSubjectRoleId);
        if (req.legalEntityId.length > 0) bp.legalEntityId = LegalEntityId(req.legalEntityId);
        if (req.referenceDate > 0) bp.referenceDate = req.referenceDate;
        bp.status = BusinessPurposeStatus.inactive;
        bp.updatedAt = clockSeconds();

        repo.update(bp);
        return CommandResult(true, id.value, "");
    }

    CommandResult activate(string id) { return activate(BusinessPurposeId(id)); }

    CommandResult activate(BusinessPurposeId id) {
        if (!repo.existsById(id)) return CommandResult(false, "", "Business purpose not found");

        auto bp = repo.findById(id);
        bp.status = BusinessPurposeStatus.active;
        bp.updatedAt = clockSeconds();
        repo.update(bp);
        return CommandResult(true, id.value, "");
    }

    bool hasById(string id) { return hasById(BusinessPurposeId(id)); }
    bool hasById(BusinessPurposeId id) { return repo.existsById(id); }
    BusinessPurpose getById(string id) { return getById(BusinessPurposeId(id)); }
    BusinessPurpose getById(BusinessPurposeId id) { return repo.findById(id); }
    BusinessPurpose[] list(TenantId tenantId) { return list(TenantId(tenantId)); }
    BusinessPurpose[] list(TenantId tenantId) { return repo.findAll(tenantId); }
    BusinessPurpose[] listByApplicationGroup(TenantId tenantId, ApplicationGroupId groupId) {
        return repo.findByApplicationGroup(tenantId, groupId);
    }

    CommandResult remove(string id) { return remove(BusinessPurposeId(id)); }
    CommandResult remove(BusinessPurposeId id) {
        if (!repo.existsById(id)) return CommandResult(false, "", "Business purpose not found");
        auto bp = repo.findById(id);
        if (bp.status == BusinessPurposeStatus.active)
            return CommandResult(false, "", "Cannot delete an active business purpose");
        repo.removeById(id);
        return CommandResult(true, id.value, "");
    }
}
