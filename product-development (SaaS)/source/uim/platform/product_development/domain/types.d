/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.product_development.domain.types;

import uim.platform.product_development;

mixin(ShowModule!());

@safe:

// --- ID Aliases ---
alias ProductId = string;
alias BillOfMaterialId = string;
alias ChangeRequestId = string;
alias DocumentId = string;
alias SpecificationId = string;
alias RecipeId = string;
alias CollaborationId = string;
alias ProductStructureId = string;
alias TenantId = string;
alias UserId = string;

// --- Enumerations ---

enum ProductType {
    discrete,
    process,
    configurable,
    variant,
    service,
    spare,
    rawMaterial,
    semiFinished,
    finished,
    custom
}

enum ProductStatus {
    draft,
    inDevelopment,
    inReview,
    approved,
    released,
    obsolete,
    discontinued
}

enum LifecyclePhase {
    concept,
    design,
    prototype,
    testing,
    production,
    maintenance,
    endOfLife
}

enum BomType {
    engineering,
    manufacturing,
    sales,
    service,
    design
}

enum BomItemType {
    component,
    assembly,
    rawMaterial,
    phantom,
    reference,
    alternateItem
}

enum ChangeRequestStatus {
    draft,
    submitted,
    inReview,
    approved,
    rejected,
    implemented,
    closed
}

enum ChangeRequestPriority {
    critical,
    high,
    medium,
    low
}

enum ChangeCategory {
    designChange,
    processChange,
    materialChange,
    specificationChange,
    corrective,
    preventive,
    regulatory
}

enum DocumentType {
    drawing,
    specification,
    manual,
    testReport,
    certifcate,
    cadModel,
    dataSheet,
    procedure,
    standard,
    image,
    other
}

enum DocumentStatus {
    draft,
    inReview,
    approved,
    released,
    superseded,
    archived
}

enum SpecificationType {
    material,
    functional,
    performance,
    dimensional,
    chemical,
    environmental,
    safety,
    regulatory,
    quality,
    custom
}

enum SpecificationStatus {
    draft,
    active,
    underRevision,
    approved,
    obsolete
}

enum RecipeStatus {
    draft,
    experimental,
    validated,
    approved,
    released,
    obsolete
}

enum RecipeType {
    master,
    variant,
    trial,
    scaleUp,
    production
}

enum CollaborationStatus {
    open,
    inProgress,
    waitingForInput,
    resolved,
    closed
}

enum CollaborationType {
    designReview,
    changeDiscussion,
    approvalRequest,
    issueReport,
    taskAssignment,
    feedback,
    question
}

enum StructureNodeType {
    product,
    assembly,
    component,
    module_,
    variant,
    option
}
