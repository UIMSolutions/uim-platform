/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logistic_management.infrastructure.container;
import uim.platform.logistic_management;

// mixin(ShowModule!());

@safe:
struct Container {
  // Repositories
  MemoryCarrierRepository        carrierRepo;
  MemoryFreightOrderRepository   freightOrderRepo;
  MemoryShipmentRepository       shipmentRepo;
  MemoryDeliveryRepository       deliveryRepo;
  MemoryWarehouseOrderRepository warehouseOrderRepo;
  MemoryWarehouseTaskRepository  warehouseTaskRepo;

  // Domain services
  LogisticsPlanner logisticsPlanner;

  // Use cases
  ManageCarriersUseCase        carriers;
  ManageFreightOrdersUseCase   freightOrders;
  ManageShipmentsUseCase       shipments;
  ManageDeliveriesUseCase      deliveries;
  ManageWarehouseOrdersUseCase warehouseOrders;
  ManageWarehouseTasksUseCase  warehouseTasks;

  // Controllers
  CarrierController        carrierCtrl;
  FreightOrderController   freightOrderCtrl;
  ShipmentController       shipmentCtrl;
  DeliveryController       deliveryCtrl;
  WarehouseOrderController warehouseOrderCtrl;
  WarehouseTaskController  warehouseTaskCtrl;
  HealthController         healthCtrl;
}

Container buildContainer(SrvConfig cfg) @safe {
  Container c;

  // Repositories
  c.carrierRepo        = new MemoryCarrierRepository();
  c.freightOrderRepo   = new MemoryFreightOrderRepository();
  c.shipmentRepo       = new MemoryShipmentRepository();
  c.deliveryRepo       = new MemoryDeliveryRepository();
  c.warehouseOrderRepo = new MemoryWarehouseOrderRepository();
  c.warehouseTaskRepo  = new MemoryWarehouseTaskRepository();

  // Domain services
  c.logisticsPlanner = new LogisticsPlanner(c.carrierRepo);

  // Use cases
  c.carriers        = new ManageCarriersUseCase(c.carrierRepo);
  c.freightOrders   = new ManageFreightOrdersUseCase(c.freightOrderRepo, c.logisticsPlanner);
  c.shipments       = new ManageShipmentsUseCase(c.shipmentRepo);
  c.deliveries      = new ManageDeliveriesUseCase(c.deliveryRepo, c.warehouseOrderRepo, c.logisticsPlanner);
  c.warehouseOrders = new ManageWarehouseOrdersUseCase(c.warehouseOrderRepo, c.warehouseTaskRepo);
  c.warehouseTasks  = new ManageWarehouseTasksUseCase(c.warehouseTaskRepo, c.logisticsPlanner);

  // Controllers
  c.carrierCtrl        = new CarrierController(c.carriers);
  c.freightOrderCtrl   = new FreightOrderController(c.freightOrders);
  c.shipmentCtrl       = new ShipmentController(c.shipments);
  c.deliveryCtrl       = new DeliveryController(c.deliveries);
  c.warehouseOrderCtrl = new WarehouseOrderController(c.warehouseOrders);
  c.warehouseTaskCtrl  = new WarehouseTaskController(c.warehouseTasks);
  c.healthCtrl         = new HealthController(cfg.serviceName);

  return c;
}
