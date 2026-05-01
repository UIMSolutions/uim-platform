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

    mixin DomainId;
}

struct PrivateKeyId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}

struct CertificateId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}

struct TlsConfigurationId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}

struct DomainMappingId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}

struct TrustedCertificateId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}

struct DnsRecordId  {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}
struct DomainDashboardId  {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}




