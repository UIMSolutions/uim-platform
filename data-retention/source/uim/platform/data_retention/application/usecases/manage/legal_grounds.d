/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_retention.application.usecases.manage.legal_grounds;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class ManageLegalGroundsUseCase {
    private ILegalGroundRepository repo;

    this(ILegalGroundRepository repo) {
        this.repo = repo;
    }

    UsecaseResult createLegalGround(CreateLegalGroundRequest req) {
        import std.uuid : randomUUID;

        if (req.name.isEmpty)
            return UsecaseResult(false, "", "Legal ground name is required");

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
        return UsecaseResult(true, lg.id.value, "");
    }

    UsecaseResult updateLegalGround(UpdateLegalGroundRequest req) {
        auto lg = repo.findById(req.tenantId, req.groundId);
        if (lg.isNull)
            return UsecaseResult(false, "", "Legal ground not found");

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
        return UsecaseResult(true, lg.id.value, "");
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

    UsecaseResult deleteLegalGround(TenantId tenantId, LegalGroundId id) {
        auto entity = repo.findById(tenantId, id);
        if (entity.isNull)            
            return UsecaseResult(false, "", "Legal ground not found");

        repo.remove(entity);
        return UsecaseResult(true, entity.id.value, "");
    }
}
