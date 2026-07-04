/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration_delivery.application.dto;

import uim.platform.integration_delivery;

mixin(ShowModule!());

@safe:

struct CicdRepositoryDTO {
    TenantId tenantId;
    CicdRepositoryId cicdRepositoryId;
    string name;
    string description;
    string repositoryType;
    string url;
    CredentialId credentialId;
    string defaultBranch;
    bool webhookEnabled;
    UserId createdBy;
    UserId updatedBy;
}

struct CredentialDTO {
    TenantId tenantId;
    CredentialId credentialId;
    string name;
    string description;
    string credentialType;
    string username;
    string secretRef;
    string target;
    long expiresAt;
    UserId createdBy;
    UserId updatedBy;
}

struct PipelineDTO {
    TenantId tenantId;
    PipelineId pipelineId;
    string name;
    string description;
    string pipelineType;
    string[] enabledStages;
    string configurationYaml;
    string version_;
    UserId createdBy;
    UserId updatedBy;
}

struct JobDTO {
    TenantId tenantId;
    JobId jobId;
    string name;
    string description;
    PipelineId pipelineId;
    CicdRepositoryId repositoryId;
    string branch;
    string triggerMode;
    string cronExpression;
    DeploymentTargetId deploymentTargetId;
    string configurationSource;
    bool notifyOnSuccess;
    bool notifyOnFailure;
    string notificationEmail;
    UserId createdBy;
    UserId updatedBy;
}

struct BuildDTO {
    TenantId tenantId;
    BuildId buildId;
    JobId jobId;
    string commitSha;
    string branch;
    string commitMessage;
    string commitAuthor;
    string triggerType;
    string triggerInfo;
    UserId createdBy;
}

struct StageDTO {
    TenantId tenantId;
    StageId stageId;
    BuildId buildId;
    string name;
    string stageType;
    int order_;
    bool isOptional;
    UserId createdBy;
    UserId updatedBy;
}

struct WebhookDTO {
    TenantId tenantId;
    WebhookId webhookId;
    CicdRepositoryId repositoryId;
    JobId jobId;
    string secret;
    string[] events;
    string callbackUrl;
    UserId createdBy;
    UserId updatedBy;
}

struct DeploymentTargetDTO {
    TenantId tenantId;
    DeploymentTargetId deploymentTargetId;
    string name;
    string description;
    string targetType;
    string url;
    CredentialId credentialId;
    string organization;
    string spaceOrNamespace;
    string region;
    UserId createdBy;
    UserId updatedBy;
}
