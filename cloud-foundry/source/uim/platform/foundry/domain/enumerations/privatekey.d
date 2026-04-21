module uim.platform.foundry.domain.enumerations.privatekey;

enum KeyAlgorithm {
    rsa2048,
    rsa4096,
    ecdsaP256,
    ecdsaP384,
}

enum KeyStatus {
    active,
    inactive,
    deleted,
}