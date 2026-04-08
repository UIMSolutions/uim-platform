/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.application.dto;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

struct ServiceCallDTO {
    string id;
    TenantId tenantId;
    string customerId;
    string equipmentId;
    string subject;
    string description;
    string status;
    string priority;
    string origin;
    string category;
    string serviceType;
    string contactPerson;
    string contactPhone;
    string contactEmail;
    string reportedDate;
    string dueDate;
    string resolvedDate;
    string resolution;
    string address;
    string latitude;
    string longitude;
    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;
}

struct ActivityDTO {
    string id;
    TenantId tenantId;
    string serviceCallId;
    string technicianId;
    string subject;
    string description;
    string activityType;
    string status;
    string plannedStart;
    string plannedEnd;
    string actualStart;
    string actualEnd;
    string travelTime;
    string workTime;
    string address;
    string latitude;
    string longitude;
    string notes;
    string feedbackCode;
    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;
}

struct AssignmentDTO {
    string id;
    TenantId tenantId;
    string activityId;
    string technicianId;
    string status;
    string assignedDate;
    string acceptedDate;
    string startedDate;
    string completedDate;
    string travelDistance;
    string schedulingPolicy;
    string matchScore;
    string notes;
    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;
}

struct EquipmentDTO {
    string id;
    TenantId tenantId;
    string customerId;
    string serialNumber;
    string name;
    string description;
    string equipmentType;
    string status;
    string manufacturer;
    string model;
    string installationDate;
    string warrantyEndDate;
    string locationAddress;
    string latitude;
    string longitude;
    string lastServiceDate;
    string nextServiceDate;
    string measuringPoint;
    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;
}

struct TechnicianDTO {
    string id;
    TenantId tenantId;
    string firstName;
    string lastName;
    string email;
    string phone;
    string status;
    string region;
    string address;
    string latitude;
    string longitude;
    string availabilityStart;
    string availabilityEnd;
    string maxWorkload;
    string currentWorkload;
    string travelRadius;
    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;
}

struct CustomerDTO {
    string id;
    TenantId tenantId;
    string name;
    string description;
    string customerType;
    string status;
    string contactPerson;
    string email;
    string phone;
    string address;
    string latitude;
    string longitude;
    string website;
    string industry;
    string accountNumber;
    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;
}

struct SkillDTO {
    string id;
    TenantId tenantId;
    string technicianId;
    string name;
    string description;
    string category;
    string proficiencyLevel;
    string certificationDate;
    string expirationDate;
    string certificationNumber;
    string issuingAuthority;
    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;
}

struct SmartformDTO {
    string id;
    TenantId tenantId;
    string serviceCallId;
    string activityId;
    string name;
    string description;
    string formType;
    string status;
    string templateId;
    string submittedBy;
    string submittedDate;
    string approvedBy;
    string approvedDate;
    string formData;
    string safetyLabel;
    string signatureData;
    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;
}
