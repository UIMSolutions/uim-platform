/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.solution_lifecycle.application.dto;

import uim.platform.solution_lifecycle;
mixin(ShowModule!());

@safe:

// ---------------------------------------------------------------------------
// MTA Archive DTOs
// ---------------------------------------------------------------------------

struct UploadMtaArchiveRequest {
    TenantId tenantId;
    string fileName;
    string mtaId;
    string mtaVersion;
    long   fileSizeBytes;
    string checksum;
    string uploadedBy;
    string namespace_;
    string[] targetPlatforms;
}

// ---------------------------------------------------------------------------
// MTA Deploy / Update DTOs
// ---------------------------------------------------------------------------

struct DeployMtaRequest {
    TenantId tenantId;
    string archiveId;        /// ID of a previously uploaded MtaArchive
    string solutionType;     /// "standard" | "provided" | "subscribed"
    string spaceId;
    string extensionDescriptor; /// Optional YAML extension snippet
    string deployedBy;
    string namespace_;
}

struct UpdateMtaRequest {
    TenantId tenantId;
    string mtaId;            /// Deployed MTA ID to update
    string archiveId;        /// New archive to deploy
    string extensionDescriptor;
    string updatedBy;
}

struct DeleteMtaRequest {
    TenantId tenantId;
    string mtaId;
    string deletedBy;
}

// ---------------------------------------------------------------------------
// Operation DTOs
// ---------------------------------------------------------------------------

struct AbortOperationRequest {
    TenantId tenantId;
    string operationId;
    string abortedBy;
}

// ---------------------------------------------------------------------------
// Subscription DTOs
// ---------------------------------------------------------------------------

struct SubscribeMtaRequest {
    TenantId tenantId;           /// Subscriber tenant
    string providerMtaId;      /// MTA ID provided by provider
    string providerTenantId;
    string providerSpaceId;
    string subscribedBy;
    string extensionDescriptor;
}

struct UnsubscribeMtaRequest {
    TenantId tenantId;
    string subscriptionId;
    string unsubscribedBy;
}
