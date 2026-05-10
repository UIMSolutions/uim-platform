/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.masterdata_governance.application.dtos.dto;

import uim.platform.masterdata_governance;

mixin(ShowModule!());

@safe:

struct BusinessPartnerDTO {
    BusinessPartnerId businessPartnerId;
    TenantId tenantId;
    string bpNumber;
    string category;
    string status;
    string legalForm;
    string firstName;
    string lastName;
    string title;
    string gender;
    string dateOfBirth;
    string nationality;
    string organizationName;
    string organizationNameAdditional;
    string industryCode;
    string industryDescription;
    string email;
    string phone;
    string mobile;
    string fax;
    string website;
    string street;
    string houseNumber;
    string postalCode;
    string city;
    string region;
    string country;
    string addressType;
    string taxNumber;
    string vatNumber;
    string taxJurisdiction;
    string roles;
    string bankAccountNumber;
    string bankRoutingNumber;
    string bankName;
    string bankCountry;
    string externalBpId;
    string sourceSystem;
    string searchTerms;
    string language;
    UserId createdBy;
    UserId updatedBy;
}

struct ChangeRequestDTO {
    ChangeRequestId changeRequestId;
    TenantId tenantId;
    BusinessPartnerId businessPartnerId;
    string status;
    string requestType;
    string subject;
    string description;
    string changedFields;
    string proposedValues;
    string currentValues;
    string comments;
    string reviewerComments;
    string dueDate;
    int priority;
    string externalReference;
    UserId requestedBy;
    UserId reviewedBy;
    UserId decidedBy;
}

struct DataQualityRuleDTO {
    DataQualityRuleId ruleId;
    TenantId tenantId;
    string name;
    string description;
    string fieldName;
    string fieldPath;
    string ruleType;
    string severity;
    string condition;
    string errorMessage;
    string bpCategory;
    bool isActive;
    int weight;
    string validValues;
    string regexPattern;
    string minValue;
    string maxValue;
    UserId createdBy;
    UserId updatedBy;
}

struct DataQualityScoreDTO {
    DataQualityScoreId scoreId;
    TenantId tenantId;
    BusinessPartnerId businessPartnerId;
    int overallScore;
    int completenessScore;
    int consistencyScore;
    int accuracyScore;
    int uniquenessScore;
    string qualityStatus;
    string evaluationDetails;
    UserId createdBy;
    UserId updatedBy;
}

struct ReplicationDTO {
    ReplicationId replicationId;
    TenantId tenantId;
    BusinessPartnerId businessPartnerId;
    string targetSystem;
    string targetSystemType;
    string replicationType;
    string scheduledAt;
    string replicatedFields;
    int maxRetries;
    string correlationId;
    string batchId;
    UserId triggeredBy;
}
