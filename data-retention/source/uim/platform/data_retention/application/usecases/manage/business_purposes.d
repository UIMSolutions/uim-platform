module uim.platform.data_retention.application.usecases.manage.business_purposes;
import uim.platform.data_retention;
mixin(ShowModule!());

@safe:

class ManageBusinessPurposesUseCase { // TODO: UIMUseCase {
    private BusinessPurposeRepository repo;

    this(BusinessPurposeRepository repo) {
        this.repo = repo;
    }

    CommandResult createBusinessPurpose(CreateBusinessPurposeRequest req) {
        import std.uuid : randomUUID;

        if (req.name.isEmpty)
            return CommandResult(false, "", "Business purpose name is required");

        auto bp = BusinessPurpose(req.tenantId);y);
        bp.name = req.name;
        bp.description = req.description;
        bp.applicationGroupId = ApplicationGroupId(req.applicationGroupId);
        bp.dataSubjectRoleId = DataSubjectRoleId(req.dataSubjectRoleId);
        bp.legalEntityId = LegalEntityId(req.legalEntityId);
        bp.referenceDate = req.referenceDate;
        bp.status = BusinessPurposeStatus.inactive;

        repo.save(bp);
        return CommandResult(true, bp.id.value, "");
    }

    CommandResult updateBusinessPurpose(UpdateBusinessPurposeRequest req) {
        auto bp = repo.findById(req.tenantId, BusinessPurposeId(req.id));
        if (bp.isNull)
            return CommandResult(false, "", "Business purpose not found");

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
        return CommandResult(true, req.id, "");
    }

    CommandResult activateBusinessPurpose(TenantId tenantId, BusinessPurposeId id) {
        auto bp = repo.findById(tenantId, id);
        if (bp.isNull)
            return CommandResult(false, "", "Business purpose not found");

        bp.status = BusinessPurposeStatus.active;
        bp.updatedAt = clockSeconds();
        repo.update(bp);
        return CommandResult(true, id.value, "");
    }

    bool hasBusinessPurpose(TenantId tenantId, BusinessPurposeId id) {
        return repo.existsById(tenantId, id);
    }

    BusinessPurpose getBusinessPurpose(TenantId tenantId, BusinessPurposeId id) {
        return repo.findById(tenantId, id);
    }

    BusinessPurpose[] listBusinessPurposes(TenantId tenantId) {
        return repo.findAll(tenantId);
    }

    BusinessPurpose[] listBusinessPurposes(TenantId tenantId, ApplicationGroupId groupId) {
        return repo.findByApplicationGroup(tenantId, groupId);
    }

    CommandResult deleteBusinessPurpose(TenantId tenantId, BusinessPurposeId id) {
        auto purpose = repo.findById(tenantId, id);
        if (purpose.isNull)
            return CommandResult(false, "", "Business purpose not found");
        
        if (purpose.status == BusinessPurposeStatus.active)
            return CommandResult(false, "", "Cannot delete an active business purpose");
        
        repo.remove(purpose);
        return CommandResult(true, purpose.id.value, "");
    }
}
