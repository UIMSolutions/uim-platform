module domain.types;

/// Unique identifier type aliases for type safety.
alias ContentPackageId = string;
alias ContentTypeId = string;
alias ContentProviderId = string;
alias TransportRequestId = string;
alias ExportJobId = string;
alias ImportJobId = string;
alias TransportQueueId = string;
alias ContentActivityId = string;
alias TenantId = string;
alias SubaccountId = string;

/// Status of a content package.
enum PackageStatus
{
    draft,
    assembled,
    exported,
    inTransport,
    delivered,
    error,
}

/// Content format for package assembly.
enum ContentFormat
{
    mtar,
    zip,
    json,
}

/// Status of a content provider.
enum ProviderStatus
{
    active,
    inactive,
    error,
    deregistered,
}

/// Content category provided by a content provider.
enum ContentCategory
{
    integrationFlow,
    destination,
    apiProxy,
    valueMapping,
    securityArtifact,
    messageMapping,
    scriptCollection,
    dataType,
    messageType,
    numberRange,
    customForm,
    workflow,
    businessRule,
    keyValueMap,
    oauthCredential,
    certificateToUserMapping,
    accessPolicy,
    functionLibrary,
    custom,
}

/// Status of a transport request.
enum TransportStatus
{
    created,
    readyForExport,
    exporting,
    exported,
    inQueue,
    importing,
    imported,
    released,
    failed,
    cancelled,
}

/// Status of an export job.
enum ExportStatus
{
    pending,
    assembling,
    packaging,
    uploading,
    completed,
    failed,
    cancelled,
}

/// Status of an import job.
enum ImportStatus
{
    pending,
    downloading,
    validating,
    deploying,
    completed,
    failed,
    cancelled,
}

/// Transport mode.
enum TransportMode
{
    cloudTransportManagement,
    ctsPlus,
    directExport,
    fileDownload,
}

/// Type of transport queue.
enum QueueType
{
    cloudTMS,
    ctsPlus,
    local,
}

/// Type of recorded activity.
enum ActivityType
{
    packageCreated,
    packageAssembled,
    packageExported,
    packageImported,
    packageDeleted,
    providerRegistered,
    providerDeregistered,
    transportCreated,
    transportReleased,
    transportFailed,
    exportStarted,
    exportCompleted,
    exportFailed,
    importStarted,
    importCompleted,
    importFailed,
    queueConfigured,
}

/// Severity level for activities.
enum ActivitySeverity
{
    info,
    warning,
    error,
}
