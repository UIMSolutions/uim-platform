module uim.platform.data_retention.application.usecases.manage.legal_grounds;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class ManageLegalGroundsUseCase { // TODO: UIMUseCase {
    private ILegalGroundRepository repo;

    this(ILegalGroundRepository repo) {
        this.repo = repo;
    }

    CommandResult createLegalGround(CreateLegalGroundRequest req) {
        import std.uuid : randomUUID;

        if (req.name.isEmpty)
            return CommandResult(false, "", "Legal ground name is required");

        LegalGround lg;
        lg.id = LegalGroundId(generateId);
        lg.tenantId = req.tenantId;
        lg.businessPurposeId = BusinessPurposeId(req.businessPurposeId);
        lg.name = req.name;
        lg.description = req.description;
        lg.type = req.type.toLegalGroundType;
        lg.referenceDate = req.referenceDate;
        lg.isActive = true;
        lg.createdBy = req.createdBy;
        lg.createdAt = clockSeconds();

        repo.save(lg);
        return CommandResult(true, lg.id.value, "");
    }

    CommandResult updateLegalGround(UpdateLegalGroundRequest req) {
        auto lg = repo.findById(req.tenantId, req.groundId);
        if (lg.isNull)
            return CommandResult(false, "", "Legal ground not found");

        if (req.name.length > 0)
            lg.name = req.name;
        if (req.description.length > 0)
            lg.description = req.description;
        if (req.type.length > 0)
            lg.type = req.type.toLegalGroundType;
        if (req.referenceDate > 0)
            lg.referenceDate = req.referenceDate;
        lg.updatedAt = clockSeconds();

        repo.update(lg);
        return CommandResult(true, lg.id.value, "");
    }

    bool hasLegalGround(TenantId tenantId, LegalGroundId id) {
        return repo.existsById(tenantId, id);
    }

    LegalGround getLegalGround(TenantId tenantId, LegalGroundId id) {
        return repo.findById(tenantId, id);
    }

    LegalGround[] listLegalGrounds(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    LegalGround[] listLegalGrounds(TenantId tenantId, BusinessPurposeId purposeId) {
        return repo.findByBusinessPurpose(tenantId, purposeId);
    }

    CommandResult deleteLegalGround(TenantId tenantId, LegalGroundId id) {
        auto entity = repo.findById(tenantId, id);
        if (entity.isNull)            
            return CommandResult(false, "", "Legal ground not found");

        repo.remove(entity);
        return CommandResult(true, entity.id.value, "");
    }
}
