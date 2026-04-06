/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.asset_strategy_performance.application.usecases.manage.manage_indicators;

import uim.platform.asset_strategy_performance;

mixin(ShowModule!());

@safe:

class ManageIndicatorsUseCase : UIMUseCase {
    private IndicatorRepository repo;

    this(IndicatorRepository repo) {
        this.repo = repo;
    }

    Indicator* get_(IndicatorId id) {
        return repo.findById(id);
    }

    Indicator[] list() {
        return repo.findAll();
    }

    Indicator[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    Indicator[] listByEquipment(EquipmentId equipmentId) {
        return repo.findByEquipment(equipmentId);
    }

    Indicator[] listByType(IndicatorType indicatorType) {
        return repo.findByType(indicatorType);
    }

    CommandResult create(IndicatorDTO dto) {
        Indicator ind;
        ind.id = dto.id;
        ind.tenantId = dto.tenantId;
        ind.equipmentId = dto.equipmentId;
        ind.modelId = dto.modelId;
        ind.name = dto.name;
        ind.description = dto.description;
        ind.value_ = dto.value_;
        ind.unit = dto.unit;
        ind.thresholdWarning = dto.thresholdWarning;
        ind.thresholdCritical = dto.thresholdCritical;
        ind.measuredAt = dto.measuredAt;
        ind.createdBy = dto.createdBy;
        if (!StrategyValidator.isValidIndicator(ind))
            return CommandResult(false, "", "Invalid indicator data");
        repo.save(ind);
        return CommandResult(true, dto.id, "");
    }

    CommandResult remove(IndicatorId id) {
        auto existing = repo.findById(id);
        if (existing is null)
            return CommandResult(false, "", "Indicator not found");
        repo.remove(id);
        return CommandResult(true, id, "");
    }
}
