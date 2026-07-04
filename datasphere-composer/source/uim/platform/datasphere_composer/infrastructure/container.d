/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere_composer.infrastructure.container;

import uim.platform.datasphere_composer;

mixin(ShowModule!());

@safe:
struct Container {
  // Repositories
  MemoryDataProviderRepository    dataProviderRepo;
  MemoryDataProductRepository     dataProductRepo;
  MemoryUnificationRuleRepository unificationRuleRepo;
  MemoryDataSourceConfigRepository dataSourceConfigRepo;
  MemoryAttributeMappingRepository attributeMappingRepo;
  MemoryCustomerProfileRepository customerProfileRepo;
  MemoryCompositionRunRepository  compositionRunRepo;
  MemoryTenantUserRepository      tenantUserRepo;

  // Use Cases
  ManageDataProvidersUseCase    dataProviders;
  ManageDataProductsUseCase     dataProducts;
  ManageUnificationRulesUseCase unificationRules;
  ManageDataSourceConfigsUseCase dataSourceConfigs;
  ManageAttributeMappingsUseCase attributeMappings;
  ManageCustomerProfilesUseCase customerProfiles;
  ManageCompositionRunsUseCase  compositionRuns;
  ManageTenantUsersUseCase      tenantUsers;

  // Controllers
  HealthController             healthCtrl;
  DataProviderController       dataProviderCtrl;
  DataProductController        dataProductCtrl;
  UnificationRuleController    unificationRuleCtrl;
  DataSourceConfigController   dataSourceConfigCtrl;
  AttributeMappingController   attributeMappingCtrl;
  CustomerProfileController    customerProfileCtrl;
  CompositionRunController     compositionRunCtrl;
  TenantUserController         tenantUserCtrl;
}

Container buildContainer(SrvConfig cfg) {
  Container c;

  c.dataProviderRepo       = new MemoryDataProviderRepository();
  c.dataProductRepo        = new MemoryDataProductRepository();
  c.unificationRuleRepo    = new MemoryUnificationRuleRepository();
  c.dataSourceConfigRepo   = new MemoryDataSourceConfigRepository();
  c.attributeMappingRepo   = new MemoryAttributeMappingRepository();
  c.customerProfileRepo    = new MemoryCustomerProfileRepository();
  c.compositionRunRepo     = new MemoryCompositionRunRepository();
  c.tenantUserRepo         = new MemoryTenantUserRepository();

  c.dataProviders    = new ManageDataProvidersUseCase(c.dataProviderRepo);
  c.dataProducts     = new ManageDataProductsUseCase(c.dataProductRepo);
  c.unificationRules = new ManageUnificationRulesUseCase(c.unificationRuleRepo);
  c.dataSourceConfigs = new ManageDataSourceConfigsUseCase(c.dataSourceConfigRepo);
  c.attributeMappings = new ManageAttributeMappingsUseCase(c.attributeMappingRepo);
  c.customerProfiles  = new ManageCustomerProfilesUseCase(c.customerProfileRepo);
  c.compositionRuns   = new ManageCompositionRunsUseCase(c.compositionRunRepo);
  c.tenantUsers       = new ManageTenantUsersUseCase(c.tenantUserRepo);

  c.healthCtrl          = new HealthController();
  c.dataProviderCtrl    = new DataProviderController(c.dataProviders);
  c.dataProductCtrl     = new DataProductController(c.dataProducts);
  c.unificationRuleCtrl = new UnificationRuleController(c.unificationRules);
  c.dataSourceConfigCtrl = new DataSourceConfigController(c.dataSourceConfigs);
  c.attributeMappingCtrl = new AttributeMappingController(c.attributeMappings);
  c.customerProfileCtrl  = new CustomerProfileController(c.customerProfiles);
  c.compositionRunCtrl   = new CompositionRunController(c.compositionRuns);
  c.tenantUserCtrl       = new TenantUserController(c.tenantUsers);

  return c;
}
