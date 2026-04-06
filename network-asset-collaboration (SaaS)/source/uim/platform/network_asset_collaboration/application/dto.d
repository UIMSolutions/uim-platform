/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.network_asset_collaboration.application.dto;

import uim.platform.network_asset_collaboration;

mixin(ShowModule!());

@safe:

struct EquipmentDTO {
    string id;
    string tenantId;
    string modelId;
    string serialNumber;
    string name;
    string description;
    string status;
    string manufacturer;
    string operatorCompanyId;
    string location;
    string latitude;
    string longitude;
    string installationDate;
    string commissioningDate;
    string warrantyEndDate;
    string batchNumber;
    string firmwareVersion;
    string[] externalIds;
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
    string imageUrl;
    bool isPublished;
    string[] supportedIndicators;
    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;
}

struct CompanyProfileDTO {
    string id;
    string tenantId;
    string name;
    string description;
    string companyType;
    string status;
    string industry;
    string website;
    string contactEmail;
    string contactPhone;
    string addressStreet;
    string addressCity;
    string addressState;
    string addressCountry;
    string addressPostalCode;
    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;
}

struct DocumentDTO {
    string id;
    string tenantId;
    string equipmentId;
    string modelId;
    string name;
    string description;
    string documentType;
    string status;
    string version_;
    string fileName;
    string fileSize;
    string mimeType;
    string language;
    string uploadedBy;
    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;
}

struct AnnouncementDTO {
    string id;
    string tenantId;
    string title;
    string description;
    string announcementType;
    string severity;
    string status;
    string publisherId;
    string[] affectedModelIds;
    string[] affectedEquipmentIds;
    string effectiveDate;
    string expiryDate;
    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;
}

struct FailureModeDTO {
    string id;
    string tenantId;
    string modelId;
    string name;
    string description;
    string severity;
    string cause;
    string effect;
    string detection;
    string mitigation;
    string riskPriorityNumber;
    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;
}

struct SparePartDTO {
    string id;
    string tenantId;
    string modelId;
    string equipmentId;
    string partNumber;
    string name;
    string description;
    string manufacturer;
    string category;
    long quantity;
    string unit;
    string leadTimeDays;
    bool isCritical;
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
