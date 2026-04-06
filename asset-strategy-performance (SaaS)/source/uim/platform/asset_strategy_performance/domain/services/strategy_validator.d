/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.asset_strategy_performance.domain.services.strategy_validator;

import uim.platform.asset_strategy_performance;

mixin(ShowModule!());

@safe:

struct StrategyValidator {
    static bool isValidEquipment(Equipment e) {
        return e.name.length > 0 && e.serialNumber.length > 0 && e.tenantId.length > 0;
    }

    static bool isValidModel(Model m) {
        return m.name.length > 0 && m.manufacturer.length > 0 && m.tenantId.length > 0;
    }

    static bool isValidLocation(Location l) {
        return l.name.length > 0 && l.tenantId.length > 0;
    }

    static bool isValidFailureMode(FailureMode fm) {
        return fm.name.length > 0 && fm.tenantId.length > 0 && (fm.modelId.length > 0 || fm.equipmentId.length > 0);
    }

    static bool isValidAssessment(Assessment a) {
        return a.name.length > 0 && a.tenantId.length > 0;
    }

    static bool isValidInstruction(Instruction i) {
        return i.name.length > 0 && i.tenantId.length > 0;
    }

    static bool isValidFunction(Function f) {
        return f.name.length > 0 && f.tenantId.length > 0;
    }

    static bool isValidIndicator(Indicator ind) {
        return ind.name.length > 0 && ind.tenantId.length > 0 && ind.equipmentId.length > 0;
    }
}
