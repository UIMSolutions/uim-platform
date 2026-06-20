module uim.platform.custom_domain.domain.types;

import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:
// ID aliases
struct CustomDomainId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}

struct OrgId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}

struct PrivateKeyId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}

struct CertificateId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}

struct TlsConfigurationId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}

struct DomainMappingId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}

struct TrustedCertificateId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}

struct DnsRecordId  {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}
struct DomainDashboardId  {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

