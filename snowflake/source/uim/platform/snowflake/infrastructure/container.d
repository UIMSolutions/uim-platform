module uim.platform.snowflake.infrastructure.container;
import uim.platform.snowflake;
mixin(ShowModule!());
@safe:
struct Container {
  // Repositories
  MemorySnowflakeAccountRepository   accountRepo;
  MemoryZerocopyConnectorRepository  connectorRepo;
  MemorySnowflakeWarehouseRepository warehouseRepo;
  MemorySnowflakeDatabaseRepository  databaseRepo;
  MemoryDataProductShareRepository   shareRepo;
  MemorySnowflakeRoleRepository      roleRepo;
  MemorySnowflakeTenantUserRepository tenantUserRepo;
  MemoryProvisioningRequestRepository provisioningRepo;

  // Use Cases
  ManageSnowflakeAccountsUseCase    accounts;
  ManageZerocopyConnectorsUseCase   connectors;
  ManageSnowflakeWarehousesUseCase  warehouses;
  ManageSnowflakeDatabasesUseCase   databases;
  ManageDataProductSharesUseCase    shares;
  ManageSnowflakeRolesUseCase       roles;
  ManageSnowflakeTenantUsersUseCase tenantUsers;
  ManageProvisioningRequestsUseCase provisioning;

  // Controllers
  HealthController              healthCtrl;
  SnowflakeAccountController    accountCtrl;
  ZerocopyConnectorController   connectorCtrl;
  SnowflakeWarehouseController  warehouseCtrl;
  SnowflakeDatabaseController   databaseCtrl;
  DataProductShareController    shareCtrl;
  SnowflakeRoleController       roleCtrl;
  SnowflakeTenantUserController tenantUserCtrl;
  ProvisioningRequestController provisioningCtrl;
}

Container buildContainer(SrvConfig cfg) {
  Container c;

  c.accountRepo     = new MemorySnowflakeAccountRepository();
  c.connectorRepo   = new MemoryZerocopyConnectorRepository();
  c.warehouseRepo   = new MemorySnowflakeWarehouseRepository();
  c.databaseRepo    = new MemorySnowflakeDatabaseRepository();
  c.shareRepo       = new MemoryDataProductShareRepository();
  c.roleRepo        = new MemorySnowflakeRoleRepository();
  c.tenantUserRepo  = new MemorySnowflakeTenantUserRepository();
  c.provisioningRepo = new MemoryProvisioningRequestRepository();

  c.accounts    = new ManageSnowflakeAccountsUseCase(c.accountRepo);
  c.connectors  = new ManageZerocopyConnectorsUseCase(c.connectorRepo);
  c.warehouses  = new ManageSnowflakeWarehousesUseCase(c.warehouseRepo);
  c.databases   = new ManageSnowflakeDatabasesUseCase(c.databaseRepo);
  c.shares      = new ManageDataProductSharesUseCase(c.shareRepo);
  c.roles       = new ManageSnowflakeRolesUseCase(c.roleRepo);
  c.tenantUsers = new ManageSnowflakeTenantUsersUseCase(c.tenantUserRepo);
  c.provisioning = new ManageProvisioningRequestsUseCase(c.provisioningRepo);

  c.healthCtrl      = new HealthController();
  c.accountCtrl     = new SnowflakeAccountController(c.accounts);
  c.connectorCtrl   = new ZerocopyConnectorController(c.connectors);
  c.warehouseCtrl   = new SnowflakeWarehouseController(c.warehouses);
  c.databaseCtrl    = new SnowflakeDatabaseController(c.databases);
  c.shareCtrl       = new DataProductShareController(c.shares);
  c.roleCtrl        = new SnowflakeRoleController(c.roles);
  c.tenantUserCtrl  = new SnowflakeTenantUserController(c.tenantUsers);
  c.provisioningCtrl = new ProvisioningRequestController(c.provisioning);

  return c;
}
