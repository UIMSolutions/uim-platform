module uim.platform.xyz.domain.entities.address_record;

import uim.platform.xyz.domain.types;

/// An address record for cleansing and geocoding.
struct AddressRecord
{
    AddressId id;
    TenantId tenantId;
    RecordId sourceRecordId;    // link to originating record

    // Input fields
    string inputLine1;
    string inputLine2;
    string inputCity;
    string inputRegion;
    string inputPostalCode;
    string inputCountry;

    // Cleansed output
    string line1;
    string line2;
    string city;
    string region;
    string postalCode;
    string country;
    string countryIso2;

    AddressType addressType = AddressType.unknown;
    AddressQuality quality = AddressQuality.unverifiable;

    // Geocoding
    double latitude = 0.0;
    double longitude = 0.0;
    GeocodePrecision geocodePrecision = GeocodePrecision.none;

    // Metadata
    CleansingAction[] appliedActions;
    string[] changeLog;         // human-readable changes
    long cleansedAt;
    long geocodedAt;
}
