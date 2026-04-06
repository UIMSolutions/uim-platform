/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.asset_strategy_performance.domain.types;

import uim.platform.asset_strategy_performance;

mixin(ShowModule!());

@safe:

// --- ID Aliases ---
alias EquipmentId = string;
alias ModelId = string;
alias LocationId = string;
alias FailureModeId = string;
alias AssessmentId = string;
alias InstructionId = string;
alias FunctionId = string;
alias IndicatorId = string;
alias TenantId = string;
alias UserId = string;

// --- Enumerations ---

enum EquipmentStatus {
    active,
    inactive,
    inMaintenance,
    decommissioned,
    underReview,
    reserved
}

enum ModelCategory {
    mechanical,
    electrical,
    electronic,
    hydraulic,
    pneumatic,
    rotating,
    structural,
    instrumentation,
    custom
}

enum LocationType {
    functional,
    spatial,
    processRelated,
    system
}

enum LocationStatus {
    active,
    inactive,
    underConstruction,
    decommissioned
}

enum FailureSeverity {
    critical,
    major,
    moderate,
    minor,
    negligible
}

enum FailureCategory {
    mechanical,
    electrical,
    instrumentation,
    processRelated,
    structural,
    corrosion,
    fatigue,
    wear,
    external,
    other
}

enum AssessmentType {
    riskCriticality,
    fmea,
    rcm,
    checklist
}

enum AssessmentStatus {
    draft,
    inProgress,
    completed,
    approved,
    rejected,
    archived
}

enum InstructionType {
    maintenance,
    inspection,
    repair,
    replacement,
    calibration,
    lubrication,
    cleaning,
    testing
}

enum InstructionPriority {
    critical,
    high,
    medium,
    low
}

enum FunctionStatus {
    operational,
    degraded,
    failed,
    unknown
}

enum IndicatorType {
    temperature,
    pressure,
    vibration,
    humidity,
    voltage,
    current,
    rpm,
    flowRate,
    oilAnalysis,
    corrosionRate,
    custom
}

enum IndicatorStatus {
    normal,
    warning,
    critical,
    unknown
}
