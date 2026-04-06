/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.product_development.application.dto;

import uim.platform.product_development;

mixin(ShowModule!());

@safe:

struct ProductDTO {
    string id;
    string tenantId;
    string name;
    string description;
    string productType;
    string status;
    string lifecyclePhase;
    string version_;
    string productNumber;
    string manufacturer;
    string category;
    string baseUnit;
    string weight;
    string weightUnit;
    string validFrom;
    string validTo;
    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;
}

struct BillOfMaterialDTO {
    string id;
    string tenantId;
    string productId;
    string name;
    string description;
    string bomType;
    string version_;
    string usage;
    string plant;
    string validFrom;
    string validTo;
    string baseQuantity;
    string baseUnit;
    bool isActive;
    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;
}

struct ChangeRequestDTO {
    string id;
    string tenantId;
    string productId;
    string title;
    string description;
    string status;
    string priority;
    string category;
    string reason;
    string impact;
    string requestedBy;
    string assignedTo;
    string approvedBy;
    string requestedDate;
    string targetDate;
    string completedDate;
    string affectedDocuments;
    string affectedBoms;
    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;
}

struct DocumentDTO {
    string id;
    string tenantId;
    string productId;
    string name;
    string description;
    string documentType;
    string status;
    string version_;
    string fileName;
    string mimeType;
    string fileSize;
    string documentNumber;
    string language;
    string author;
    string approvedBy;
    string validFrom;
    string validTo;
    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;
}

struct SpecificationDTO {
    string id;
    string tenantId;
    string productId;
    string name;
    string description;
    string specificationType;
    string status;
    string version_;
    string specificationNumber;
    string property;
    string targetValue;
    string unit;
    string lowerLimit;
    string upperLimit;
    string testMethod;
    string complianceStandard;
    string approvedBy;
    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;
}

struct RecipeDTO {
    string id;
    string tenantId;
    string productId;
    string name;
    string description;
    string recipeType;
    string status;
    string version_;
    string recipeNumber;
    string yield_;
    string yieldUnit;
    string batchSize;
    string batchUnit;
    string shelfLife;
    string storageConditions;
    string ingredients;
    string instructions;
    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;
}

struct CollaborationDTO {
    string id;
    string tenantId;
    string productId;
    string title;
    string description;
    string collaborationType;
    string status;
    string assignedTo;
    string participants;
    string dueDate;
    string resolvedDate;
    string resolution;
    string relatedDocumentId;
    string relatedChangeRequestId;
    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;
}

struct ProductStructureDTO {
    string id;
    string tenantId;
    string productId;
    string name;
    string description;
    string nodeType;
    string parentNodeId;
    string position;
    string sortOrder;
    string quantity;
    string unit;
    string variantCondition;
    string configurationProfile;
    bool isMandatory;
    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;
}
