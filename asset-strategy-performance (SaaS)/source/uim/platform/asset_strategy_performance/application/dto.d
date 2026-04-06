/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.asset_strategy_performance.application.dto;

import uim.platform.asset_strategy_performance;

mixin(ShowModule!());

@safe:

struct EquipmentDTO {
    string id;
    string tenantId;
    string modelId;
    string locationId;
    string serialNumber;
    string name;
    string description;
    string status;
    string manufacturer;
    string operatorId;
    string installationDate;
    string commissioningDate;
    string warrantyEndDate;
    string criticality;
    string maintenanceStrategy;
    string lastMaintenanceDate;
    string nextMaintenanceDate;
    string firmwareVersion;
    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;
}

struct ModelDTO {
    string id;
    string tenantId;
    string name;
    string description;
    string manufacturer;
    string category;
    string version_;
    string modelNumber;
    string templateId;
    string isoStandard;
    bool isPublished;
    string[] supportedIndicators;
    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;
}

struct LocationDTO {
    string id;
    string tenantId;
    string name;
    string description;
    string locationType;
    string status;
    string parentLocationId;
    string latitude;
    string longitude;
    string address;
    string building;
    string floor;
    string room;
    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;
}

struct FailureModeDTO {
    string id;
    string tenantId;
    string modelId;
    string equipmentId;
    string name;
    string description;
    string severity;
    string category;
    string cause;
    string effect;
    string detection;
    string mitigation;
    string riskPriorityNumber;
    string occurrenceProbability;
    string detectability;
    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;
}

struct AssessmentDTO {
    string id;
    string tenantId;
    string equipmentId;
    string modelId;
    string locationId;
    string name;
    string description;
    string assessmentType;
    string status;
    string templateId;
    string score;
    string riskLevel;
    string likelihood;
    string consequence;
    string assessedBy;
    string approvedBy;
    string assessmentDate;
    string nextReviewDate;
    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;
}

struct InstructionDTO {
    string id;
    string tenantId;
    string modelId;
    string equipmentId;
    string name;
    string description;
    string instructionType;
    string priority;
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

struct FunctionDTO {
    string id;
    string tenantId;
    string equipmentId;
    string modelId;
    string locationId;
    string name;
    string description;
    string status;
    string operatingContext;
    string performanceStandard;
    string failureDefinition;
    string redundancy;
    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;
}

struct IndicatorDTO {
    string id;
    string tenantId;
    string equipmentId;
    string modelId;
    string name;
    string description;
    string indicatorType;
    string status;
    string value_;
    string unit;
    string thresholdWarning;
    string thresholdCritical;
    string measuredAt;
    string createdBy;
    string createdAt;
    string modifiedAt;
}
