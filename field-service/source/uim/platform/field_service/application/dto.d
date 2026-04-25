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
    string updatedAt;

    Json toJson() const {
        return Json.emptyObject
            .set("id", id)
            .set("tenantId", tenantId)
            .set("customerId", customerId)
            .set("equipmentId", equipmentId)
            .set("subject", subject)
            .set("description", description)
            .set("status", status)
            .set("priority", priority)
            .set("origin", origin)
            .set("category", category)
            .set("serviceType", serviceType)
            .set("contactPerson", contactPerson)
            .set("contactPhone", contactPhone)
            .set("contactEmail", contactEmail)
            .set("reportedDate", reportedDate)
            .set("dueDate", dueDate)
            .set("resolvedDate", resolvedDate)
            .set("resolution", resolution)
            .set("address", address)
            .set("latitude", latitude)
            .set("longitude", longitude)
            .set("createdBy", createdBy)
            .set("modifiedBy", modifiedBy)
            .set("createdAt", createdAt)
            .set("updatedAt", updatedAt);
    }
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
    string updatedAt;

    Json toJson() const {
        return Json.emptyObject
            .set("id", id)
            .set("tenantId", tenantId)
            .set("serviceCallId", serviceCallId)
            .set("technicianId", technicianId)
            .set("subject", subject)
            .set("description", description)
            .set("activityType", activityType)
            .set("status", status)
            .set("plannedStart", plannedStart)
            .set("plannedEnd", plannedEnd)
            .set("actualStart", actualStart)
            .set("actualEnd", actualEnd)
            .set("travelTime", travelTime)
            .set("workTime", workTime)
            .set("address", address)
            .set("latitude", latitude)
            .set("longitude", longitude)
            .set("notes", notes)
            .set("feedbackCode", feedbackCode)
            .set("createdBy", createdBy)
            .set("modifiedBy", modifiedBy)
            .set("createdAt", createdAt)
            .set("updatedAt", updatedAt);
    }
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
    string updatedAt;

    Json toJson() const {
        return Json.emptyObject
            .set("id", id)
            .set("tenantId", tenantId)
            .set("activityId", activityId)
            .set("technicianId", technicianId)
            .set("status", status)
            .set("assignedDate", assignedDate)
            .set("acceptedDate", acceptedDate)
            .set("startedDate", startedDate)
            .set("completedDate", completedDate)
            .set("travelDistance", travelDistance)
            .set("schedulingPolicy", schedulingPolicy)
            .set("matchScore", matchScore)
            .set("notes", notes)
            .set("createdBy", createdBy)
            .set("modifiedBy", modifiedBy)
            .set("createdAt", createdAt)
            .set("updatedAt", updatedAt);
    }
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
    string updatedAt;

    Json toJson() const {
        return Json.emptyObject
            .set("id", id)
            .set("tenantId", tenantId)
            .set("customerId", customerId)
            .set("serialNumber", serialNumber)
            .set("name", name)
            .set("description", description)
            .set("equipmentType", equipmentType)
            .set("status", status)
            .set("manufacturer", manufacturer)
            .set("model", model)
            .set("installationDate", installationDate)
            .set("warrantyEndDate", warrantyEndDate)
            .set("locationAddress", locationAddress)
            .set("latitude", latitude)
            .set("longitude", longitude)
            .set("lastServiceDate", lastServiceDate)
            .set("nextServiceDate", nextServiceDate)
            .set("measuringPoint", measuringPoint)
            .set("createdBy", createdBy)
            .set("modifiedBy", modifiedBy)
            .set("createdAt", createdAt)
            .set("updatedAt", updatedAt);
    }
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
    string updatedAt;

    Json toJson() const {
        return Json.emptyObject
            .set("id", id)
            .set("tenantId", tenantId)
            .set("firstName", firstName)
            .set("lastName", lastName)
            .set("email", email)
            .set("phone", phone)
            .set("status", status)
            .set("region", region)
            .set("address", address)
            .set("latitude", latitude)
            .set("longitude", longitude)
            .set("availabilityStart", availabilityStart)
            .set("availabilityEnd", availabilityEnd)
            .set("maxWorkload", maxWorkload)
            .set("currentWorkload", currentWorkload)
            .set("travelRadius", travelRadius)
            .set("createdBy", createdBy)
            .set("modifiedBy", modifiedBy)
            .set("createdAt", createdAt)
            .set("updatedAt", updatedAt);
    }
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
    string updatedAt;

    Json toJson() const {
        return Json.emptyObject
            .set("id", id)
            .set("tenantId", tenantId)
            .set("name", name)
            .set("description", description)
            .set("customerType", customerType)
            .set("status", status)
            .set("contactPerson", contactPerson)
            .set("email", email)
            .set("phone", phone)
            .set("address", address)
            .set("latitude", latitude)
            .set("longitude", longitude)
            .set("website", website)
            .set("industry", industry)
            .set("accountNumber", accountNumber)
            .set("createdBy", createdBy)
            .set("modifiedBy", modifiedBy)
            .set("createdAt", createdAt)
            .set("updatedAt", updatedAt);
    }
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
    string updatedAt;

    Json toJson() const {
        return Json.emptyObject
            .set("id", id)
            .set("tenantId", tenantId)
            .set("technicianId", technicianId)
            .set("name", name)
            .set("description", description)
            .set("category", category)
            .set("proficiencyLevel", proficiencyLevel)
            .set("certificationDate", certificationDate)
            .set("expirationDate", expirationDate)
            .set("certificationNumber", certificationNumber)
            .set("issuingAuthority", issuingAuthority)
            .set("createdBy", createdBy)
            .set("modifiedBy", modifiedBy)
            .set("createdAt", createdAt)
            .set("updatedAt", updatedAt);
    }
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
    string updatedAt;

    Json toJson() const {
        return Json.emptyObject
            .set("id", id)
            .set("tenantId", tenantId)
            .set("serviceCallId", serviceCallId)
            .set("activityId", activityId)
            .set("name", name)
            .set("description", description)
            .set("formType", formType)
            .set("status", status)
            .set("templateId", templateId)
            .set("submittedBy", submittedBy)
            .set("submittedDate", submittedDate)
            .set("approvedBy", approvedBy)
            .set("approvedDate", approvedDate)
            .set("formData", formData)
            .set("safetyLabel", safetyLabel)
            .set("signatureData", signatureData)
            .set("createdBy", createdBy)
            .set("modifiedBy", modifiedBy)
            .set("createdAt", createdAt)
            .set("updatedAt", updatedAt);
    }
}
