/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.asset_strategy_performance.domain.entities.instruction;

import uim.platform.asset_strategy_performance;

mixin(ShowModule!());

@safe:

struct Instruction {
    InstructionId id;
    TenantId tenantId;
    string modelId;
    string equipmentId;
    string name;
    string description;
    InstructionType instructionType = InstructionType.maintenance;
    InstructionPriority priority = InstructionPriority.medium;
    string version_;
    string steps;
    string safetyNotes;
    string requiredTools;
    string estimatedDuration;
    string publishedBy;
    string effectiveDate;
    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;
}
