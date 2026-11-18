/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Reference data: provider regions and storage classes.
module uim.platform.object_store.domain.services.catalogs;

import uim.platform.object_store;

mixin(ShowModule!());

@safe:

/// The regions in which SAP BTP offers the Object Store service.
immutable Region[] supportedRegions = [
  Region("eu-central-1", "Europe (Frankfurt)", IaasProvider.aws, "Frankfurt, DE"),
  Region("eu-west-1", "Europe (Ireland)", IaasProvider.aws, "Dublin, IE"),
  Region("us-east-1", "US East (N. Virginia)", IaasProvider.aws, "Virginia, US"),
  Region("us-west-2", "US West (Oregon)", IaasProvider.aws, "Oregon, US"),
  Region("ap-southeast-1", "Asia Pacific (Singapore)", IaasProvider.aws, "Singapore, SG"),
  Region("ap-northeast-1", "Asia Pacific (Tokyo)", IaasProvider.aws, "Tokyo, JP"),
  Region("sa-east-1", "South America (São Paulo)", IaasProvider.aws, "São Paulo, BR"),
  Region("westeurope", "Europe (Netherlands)", IaasProvider.azure, "Amsterdam, NL"),
  Region("northeurope", "Europe (Ireland)", IaasProvider.azure, "Dublin, IE"),
  Region("eastus", "US East (Virginia)", IaasProvider.azure, "Virginia, US"),
  Region("westus2", "US West (Washington)", IaasProvider.azure, "Washington, US"),
  Region("japaneast", "Japan East (Tokyo)", IaasProvider.azure, "Tokyo, JP"),
  Region("europe-west3", "Europe (Frankfurt)", IaasProvider.gcp, "Frankfurt, DE"),
  Region("us-central1", "US Central (Iowa)", IaasProvider.gcp, "Iowa, US"),
  Region("asia-south1", "India (Mumbai)", IaasProvider.gcp, "Mumbai, IN"),
  Region("cn-shanghai", "China (Shanghai)", IaasProvider.alibaba, "Shanghai, CN"),
];

/// The storage classes and their properties.
immutable StorageClassInfo[] storageClassCatalog = [
  StorageClassInfo("standard", "Standard", "Frequently accessed data, millisecond access", 0, 100, false),
  StorageClassInfo("infrequentAccess", "Infrequent Access", "Data accessed less than once a month", 30, 55, false),
  StorageClassInfo("nearline", "Nearline", "Data accessed about once a quarter", 30, 45, false),
  StorageClassInfo("coldline", "Coldline", "Data accessed about once a year", 90, 20, false),
  StorageClassInfo("archive", "Archive", "Long-term retention; restore before reading", 180, 5, true),
];

/// The region `id` of a provider (Region.init if not offered).
Region regionOf(IaasProvider provider, string id) {
  foreach (r; supportedRegions)
    if (r.provider == provider && r.id == id)
      return r;
  return Region.init;
}

/// The first region of a provider (default for new buckets).
string defaultRegionOf(IaasProvider provider) {
  foreach (r; supportedRegions)
    if (r.provider == provider)
      return r.id;
  return "";
}

/// Validate (and default) the region of a bucket.
string requireRegion(IaasProvider provider, string region, string configuredDefault) {
  auto id = region.strip.toLower;
  if (id.length == 0)
    id = regionOf(provider, configuredDefault).id.length > 0 ? configuredDefault : defaultRegionOf(provider);
  validate(regionOf(provider, id).id.length > 0,
    "Region '" ~ id ~ "' is not offered on " ~ enumText(provider) ~ " (see the Regions reference data)");
  return id;
}

///
unittest {
  assert(requireRegion(IaasProvider.aws, "", "eu-central-1") == "eu-central-1");
  assert(requireRegion(IaasProvider.azure, "", "eu-central-1") == "westeurope");
  assert(requireRegion(IaasProvider.gcp, "Europe-West3", "") == "europe-west3");
  bool rejected;
  try requireRegion(IaasProvider.aws, "westeurope", "");
  catch (ObjectStoreValidationException) rejected = true;
  assert(rejected);
  assert(storageClassCatalog.length == enumTexts!StorageClass.length);
}
