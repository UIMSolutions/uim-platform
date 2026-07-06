module uim.platform.custom_domain.domain.types;

import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:
// ID aliases
struct CustomDomainId {
    mixin(IdTemplate);
}

struct PrivateKeyId {
    mixin(IdTemplate);
}

struct CertificateId {
    mixin(IdTemplate);
}

struct TlsConfigurationId {
    mixin(IdTemplate);
}

struct DomainMappingId {
    mixin(IdTemplate);
}

struct TrustedCertificateId {
    mixin(IdTemplate);
}

struct DnsRecordId  {
  mixin(IdTemplate);
}
struct DomainDashboardId  {
  mixin(IdTemplate);
}

