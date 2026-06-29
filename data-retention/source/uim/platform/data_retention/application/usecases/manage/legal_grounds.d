module uim.platform.data_retention.application.usecases.manage.legal_grounds;
import uim.platform.data_retention;

// mixin(ShowModule!());

@safe:

class ManageLegalGroundsUseCase { // TODO: UIMUseCase {
    private LegalGroundRepository repo;

    this(LegalGroundRepository repo) {
        this.repo = repo;
    }

    CommandResult createLegalGround(CreateLegalGroundRequest req) {
        import std.uuid : randomUUID;

        if (req.name.length == 0)
            return CommandResult(false, "", "Legal ground name is required");

        LegalGround lg;
        lg.id = LegalGroundId(randomUUID().toString());
        lg.tenantId = req.tenantId;
        lg.businessPurposeId = BusinessPurposeId(req.businessPurposeId);
        lg.name = req.name;
        lg.description = req.description;
        lg.type = parseLegalGroundType(req.type);
        lg.referenceDate = req.referenceDate;
        lg.isActive = true;
        lg.createdBy = req.createdBy;
        lg.createdAt = clockSeconds();

        repo.save(lg);
        return CommandResult(true, lg.id.value, "");
    }

    CommandResult updateLegalGround(LegalGroundId id, UpdateLegalGroundRequest req) {
        auto lg = repo.findById(tenantId, id);
        if (lg.isNull)
            return CommandResult(false, "", "Legal ground not found");

        if (req.name.length > 0)
            lg.name = req.name;
        if (req.description.length > 0)
            lg.description = req.description;
        if (req.type.length > 0)
            lg.type = parseLegalGroundType(req.type);
        if (req.referenceDate > 0)
            lg.referenceDate = req.referenceDate;
        lg.updatedAt = clockSeconds();

        repo.update(lg);
        return CommandResult(true, id.value, "");
    }

    bool hasLegalGround(LegalGroundId id) {
        return repo.existsById(id);
    }

    LegalGround getLegalGround(LegalGroundId id) {
        return repo.findById(tenantId, id);
    }

    LegalGround[] listLegalGrounds(TenantId tenantId) {
        return repo.findAll(tenantId);
    }

    LegalGround[] listLegalGrounds(TenantId tenantId, BusinessPurposeId purposeId) {
        return repo.findByBusinessPurpose(tenantId, purposeId);
    }

    CommandResult deleteLegalGround(LegalGroundId id) {
        auto entity = repo.findById(tenantId, id);
        if (entity.isNull)            
            return CommandResult(false, "", "Legal ground not found");

        repo.remove(entity);
        return CommandResult(true, entity.id.value, "");
    }

    private static LegalGroundType parseLegalGroundType(string s) {
        switch (s) {
        case "consent":
            return LegalGroundType.consent;
        case "contract":
            return LegalGroundType.contract;
        case "legalObligation":
            return LegalGroundType.legalObligation;
        case "vitalInterest":
            return LegalGroundType.vitalInterest;
        case "publicInterest":
            return LegalGroundType.publicInterest;
        case "legitimateInterest":
            return LegalGroundType.legitimateInterest;
        default:
            return LegalGroundType.consent;
        }
    }
}
