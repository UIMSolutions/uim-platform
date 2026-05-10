/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.presentation.http.controllers.customer;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

class CustomerController : PlatformController {
    private ManageCustomersUseCase usecase;

    this(ManageCustomersUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        
        router.get("/api/v1/field-service/customers", &handleList);
        router.get("/api/v1/field-service/customers/*", &handleGet);
        router.post("/api/v1/field-service/customers", &handleCreate);
        router.put("/api/v1/field-service/customers/*", &handleUpdate);
        router.delete_("/api/v1/field-service/customers/*", &handleDelete);
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto items = usecase.listCustomers(tenantId);
            auto jarr = items.map!(e => e.toJson).array.toJson;
            
            auto resp = Json.emptyObject
              .set("count", items.length)
              .set("resources", jarr);

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = CustomerId(extractIdFromPath(path));
            
            auto customer = usecase.getCustomer(tenantId, id);
            if (customer.isNull) { writeError(res, 404, "Customer not found"); return; }
            res.writeJsonBody(customer.toJson, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;
            CustomerDTO dto;
            dto.customerId = CustomerId(j.getString("id"));
            dto.tenantId = tenantId;
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.customerType = j.getString("customerType");
            dto.contactPerson = j.getString("contactPerson");
            dto.email = j.getString("email");
            dto.phone = j.getString("phone");
            dto.address = j.getString("address");
            dto.latitude = j.getString("latitude");
            dto.longitude = j.getString("longitude");
            dto.website = j.getString("website");
            dto.industry = j.getString("industry");
            dto.accountNumber = j.getString("accountNumber");
            dto.createdBy = UserId(j.getString("createdBy"));

            auto result = usecase.createCustomer(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Customer created");

                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto j = req.json;

            CustomerDTO dto;
            dto.customerId = CustomerId(extractIdFromPath(path));
            dto.tenantId = tenantId;
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.contactPerson = j.getString("contactPerson");
            dto.email = j.getString("email");
            dto.phone = j.getString("phone");
            dto.address = j.getString("address");
            dto.updatedBy = UserId(j.getString("updatedBy"));

            auto result = usecase.updateCustomer(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Customer updated");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = CustomerId(extractIdFromPath(path));
            auto result = usecase.deleteCustomer(tenantId, id);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("message", "Customer deleted");
                  
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
