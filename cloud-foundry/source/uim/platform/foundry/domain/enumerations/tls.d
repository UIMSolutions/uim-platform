module uim.platform.foundry.domain.enumerations.tls;

enum TlsProtocolVersion {
    tls1_0,
    tls1_1,
    tls1_2,
    tls1_3,
}

enum CipherSuiteStrength {
    strong,
    medium,
    weak,
}