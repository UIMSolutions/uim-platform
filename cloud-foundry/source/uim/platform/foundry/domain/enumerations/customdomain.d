module uim.platform.foundry.domain.enumerations.customdomain;

enum DomainStatus {
    pending,
    active,
    inactive,
    error,
    deactivated,
}

enum DomainEnvironment {
    cloudFoundry,
    kyma,
    neo,
}

