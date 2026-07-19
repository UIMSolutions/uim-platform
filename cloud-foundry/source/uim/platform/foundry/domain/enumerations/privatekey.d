/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.domain.enumerations.privatekey;
import uim.platform.foundry;
mixin(ShowModule!());

@safe:
/// Represents the algorithm used for a private key.
enum KeyAlgorithm {
    /// RSA with 2048-bit key size
    rsa2048,
    /// RSA with 4096-bit key size
    rsa4096,
    /// ECDSA with P-256 curve
    ecdsaP256,
    /// ECDSA with P-384 curve  
    ecdsaP384,
}
KeyAlgorithm toKeyAlgorithm(string value) {
    mixin(EnumSwitch("KeyAlgorithm", "rsa2048"));
}
KeyAlgorithm[] toKeyAlgorithm(string[] values) {
    return values.map!(toKeyAlgorithm).array;
}
string toString(KeyAlgorithm algorithm) {
    return algorithm.to!string;
}
string[] toStrings(KeyAlgorithm[] algorithms) {
    return algorithms.map!(toString).array;
}
///
unittest {
    mixin(ShowTest!("KeyAlgorithm"));

    assert("rsa2048".toKeyAlgorithm == KeyAlgorithm.rsa2048);
    assert("rsa4096".toKeyAlgorithm == KeyAlgorithm.rsa4096);
    assert("ecdsaP256".toKeyAlgorithm == KeyAlgorithm.ecdsaP256);
    assert("ecdsaP384".toKeyAlgorithm == KeyAlgorithm.ecdsaP384);
    
    assert("unknown".toKeyAlgorithm == KeyAlgorithm.rsa2048);
    assert("".toKeyAlgorithm == KeyAlgorithm.rsa2048);
    
    assert(KeyAlgorithm.rsa2048.toString == "rsa2048");
    assert(KeyAlgorithm.rsa4096.toString == "rsa4096");
    assert(KeyAlgorithm.ecdsaP256.toString == "ecdsaP256");
    assert(KeyAlgorithm.ecdsaP384.toString == "ecdsaP384");

    assert(toString([KeyAlgorithm.rsa2048, KeyAlgorithm.ecdsaP384]) == ["rsa2048", "ecdsaP384"]);
    assert(toKeyAlgorithm(["rsa2048", "ecdsaP384"]) == [KeyAlgorithm.rsa2048, KeyAlgorithm.ecdsaP384]);
}

enum KeyStatus {
    /// The key is active and can be used for cryptographic operations.
    active,
    /// The key is inactive and cannot be used for cryptographic operations.
    inactive,
    /// The key has been deleted and is no longer available for use.
    deleted,
}
KeyStatus toKeyStatus(string value) {
    mixin(EnumSwitch("KeyStatus", "active"));
}
KeyStatus[] toKeyStatus(string[] values) {
    return values.map!(toKeyStatus).array;
}
string toString(KeyStatus status) {
    return status.to!string;
}
string[] toStrings(KeyStatus[] statuses) {
    return statuses.map!(toString).array;
}
/// 
unittest {
    mixin(ShowTest!("KeyStatus"));

    assert("active".toKeyStatus == KeyStatus.active);
    assert("inactive".toKeyStatus == KeyStatus.inactive);
    assert("deleted".toKeyStatus == KeyStatus.deleted);
    
    assert("unknown".toKeyStatus == KeyStatus.active);
    assert("".toKeyStatus == KeyStatus.active);
    
    assert(KeyStatus.active.toString == "active");
    assert(KeyStatus.inactive.toString == "inactive");
    assert(KeyStatus.deleted.toString == "deleted");

    assert(toString([KeyStatus.active, KeyStatus.deleted]) == ["active", "deleted"]);
    assert(toKeyStatus(["active", "deleted"]) == [KeyStatus.active, KeyStatus.deleted]);
}