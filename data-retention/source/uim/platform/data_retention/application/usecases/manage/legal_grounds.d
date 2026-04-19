module uim.platform.data_retention.application.usecases.manage.legal_grounds;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class ManageLegalGroundsUseCase { // TODO: UIMUseCase {
    private LegalGroundRepository repo;

    this(LegalGroundRepository repo) { this.repo = repo; }

    CommandResult create(CreateLegalGroundRequest req) {
        import std.uuid : randomUUID;
        if (req.name.length == 0) return CommandResult(false, "", "Legal ground name is required");

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

    CommandResult update(string id, UpdateLegalGroundRequest req) { return update(LegalGroundId(id), req); }

    CommandResult update(LegalGroundId id, UpdateLegalGroundRequest req) {
        if (!repo.existsById(id)) return CommandResult(false, "", "Legal ground not found");

        auto lg = repo.findById(id);
        if (req.name.length > 0) lg.name = req.name;
        if (req.description.length > 0) lg.description = req.description;
        if (req.type.length > 0) lg.type = parseLegalGroundType(req.type);
        if (req.referenceDate > 0) lg.referenceDate = req.referenceDate;
        lg.updatedAt = clockSeconds();

        repo.update(lg);
        return CommandResult(true, id.value, "");
    }

    bool hasById(string id) { return hasById(LegalGroundId(id)); }
    bool hasById(LegalGroundId id) { return repo.existsById(id); }
    LegalGround getById(string id) { return getById(LegalGroundId(id)); }
    LegalGround getById(LegalGroundId id) { return repo.findById(id); }
    LegalGround[] list(string tenantId) { return list(TenantId(tenantId)); }
    LegalGround[] list(TenantId tenantId) { return repo.findAll(tenantId); }
    LegalGround[] listByBusinessPurpose(TenantId tenantId, BusinessPurposeId purposeId) {
        return repo.findByBusinessPurpose(tenantId, purposeId);
    }
    CommandResult remove(string id) { return remove(LegalGroundId(id)); }
    CommandResult remove(LegalGroundId id) { repo.remove(id); return CommandResult(true, id.value, ""); }

    private static LegalGroundType parseLegalGroundType(string s) {
        switch (s) {
            case "consent": return LegalGroundType.consent;
            case "contract": return LegalGroundType.contract;
            case "legalObligation": return LegalGroundType.legalObligation;
            case "vitalInterest": return LegalGroundType.vitalInterest;
            case "publicInterest": return LegalGroundType.publicInterest;
            case "legitimateInterest": return LegalGroundType.legitimateInterest;
            default: return LegalGroundType.consent;
        }
    }
}
