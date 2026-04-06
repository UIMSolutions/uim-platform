/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.asset_strategy_performance.application.usecases.manage.manage_assessments;

import uim.platform.asset_strategy_performance;

mixin(ShowModule!());

@safe:

class ManageAssessmentsUseCase : UIMUseCase {
    private AssessmentRepository repo;

    this(AssessmentRepository repo) {
        this.repo = repo;
    }

    Assessment* get_(AssessmentId id) {
        return repo.findById(id);
    }

    Assessment[] list() {
        return repo.findAll();
    }

    Assessment[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    Assessment[] listByEquipment(EquipmentId equipmentId) {
        return repo.findByEquipment(equipmentId);
    }

    Assessment[] listByType(AssessmentType assessmentType) {
        return repo.findByType(assessmentType);
    }

    Assessment[] listByStatus(AssessmentStatus status) {
        return repo.findByStatus(status);
    }

    CommandResult create(AssessmentDTO dto) {
        Assessment a;
        a.id = dto.id;
        a.tenantId = dto.tenantId;
        a.equipmentId = dto.equipmentId;
        a.modelId = dto.modelId;
        a.locationId = dto.locationId;
        a.name = dto.name;
        a.description = dto.description;
        a.templateId = dto.templateId;
        a.score = dto.score;
        a.riskLevel = dto.riskLevel;
        a.likelihood = dto.likelihood;
        a.consequence = dto.consequence;
        a.assessedBy = dto.assessedBy;
        a.approvedBy = dto.approvedBy;
        a.assessmentDate = dto.assessmentDate;
        a.nextReviewDate = dto.nextReviewDate;
        a.createdBy = dto.createdBy;
        if (!StrategyValidator.isValidAssessment(a))
            return CommandResult(false, "", "Invalid assessment data");
        repo.save(a);
        return CommandResult(true, dto.id, "");
    }

    CommandResult update(AssessmentDTO dto) {
        auto existing = repo.findById(dto.id);
        if (existing is null)
            return CommandResult(false, "", "Assessment not found");
        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.score.length > 0) existing.score = dto.score;
        if (dto.riskLevel.length > 0) existing.riskLevel = dto.riskLevel;
        if (dto.modifiedBy.length > 0) existing.modifiedBy = dto.modifiedBy;
        repo.update(*existing);
        return CommandResult(true, dto.id, "");
    }

    CommandResult remove(AssessmentId id) {
        auto existing = repo.findById(id);
        if (existing is null)
            return CommandResult(false, "", "Assessment not found");
        repo.remove(id);
        return CommandResult(true, id, "");
    }
}
