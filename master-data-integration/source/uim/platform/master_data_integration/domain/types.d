module uim.platform.master_data_integration.domain.types;

/// Unique identifier type aliases for type safety.
alias MasterDataObjectId = string;
alias DataModelId = string;
alias DistributionModelId = string;
alias KeyMappingId = string;
alias ChangeLogEntryId = string;
alias ClientId = string;
alias ReplicationJobId = string;
alias FilterRuleId = string;
alias TenantId = string;
alias VersionId = string;

/// Category of master data object.
enum MasterDataCategory
{
    businessPartner,
    costCenter,
    profitCenter,
    companyCode,
    workforcePerson,
    bankAccount,
    plant,
    purchasingOrganization,
    salesOrganization,
    customerMaterial,
    supplierMaterial,
    custom,
}

/// Status of a master data record.
enum RecordStatus
{
    active,
    inactive,
    blocked,
    markedForDeletion,
}

/// Type of change in a change log.
enum ChangeType
{
    create_,
    update_,
    delete_,
    merge,
    activate,
    deactivate,
}

/// Status of a distribution model.
enum DistributionModelStatus
{
    active,
    inactive,
    draft,
}

/// Direction of data flow in distribution.
enum DistributionDirection
{
    outbound,
    inbound,
    bidirectional,
}

/// Status of a connected client system.
enum ClientStatus
{
    connected,
    disconnected,
    error,
    suspended,
}

/// Type of the connected client.
enum ClientType
{
    sapS4Hana,
    sapSuccessFactors,
    sapAriba,
    sapFieldglass,
    sapConcur,
    sapBusinessByDesign,
    thirdParty,
    custom,
}

/// Status of a replication job.
enum ReplicationJobStatus
{
    pending,
    running,
    completed,
    failed,
    cancelled,
    paused,
}

/// Trigger mode for replication.
enum ReplicationTrigger
{
    manual,
    scheduled,
    eventDriven,
    onChange,
}

/// Filter operator for filtering rules.
enum FilterOperator
{
    equals,
    notEquals,
    contains,
    startsWith,
    endsWith,
    greaterThan,
    lessThan,
    inList,
    notInList,
    between,
    isNull,
    isNotNull,
}

/// Data model field type.
enum FieldType
{
    string_,
    integer_,
    decimal_,
    boolean_,
    date,
    timestamp,
    reference,
    array_,
    object_,
}

/// Key mapping source type.
enum KeyMappingSourceType
{
    local,
    remote,
    universal,
}
