/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.presentation.http.controllers.legal_ground;

// import uim.platform.data.privacy.application.usecases.manage.legal_grounds;
// import uim.platform.data.privacy.application.dto;

// import uim.platform.data.privacy.domain.entities.legal_ground;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class LegalGroundController : ManageController {
  private ManageLegalGroundsUseCase usecase;

  this(ManageLegalGroundsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/legal-grounds", &handleCreate);
    router.get("/api/v1/legal-grounds", &handleList);
    router.get("/api/v1/legal-grounds/*", &handleGet);
    router.put("/api/v1/legal-grounds/*", &handleUpdate);
    router.delete_("/api/v1/legal-grounds/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        ScanJobDTO dto;
        dto.tenantId = tenantId;
      CreateLegalGroundRequest r;
      r.tenantId = tenantId;
      r.dataSubjectId = data.getString("dataSubjectId");
      r.basis = data.getString("basis").to!LegalBasis;
      r.purpose = data.getString("purpose");
      r.description = data.getString("description");
      r.legalReference = data.getString("legalReference");
      r.validFrom = data.getLong("validFrom");
      r.validUntil = data.getLong("validUntil");

      auto result = usecase.createGround(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Legal ground created successfully");

        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto basisParam = req.headers.get("X-Basis-Filter", "");
      auto purposeParam = req.headers.get("X-Purpose-Filter", "");
      auto subjectParam = req.headers.get("X-Subject-Filter", "");

      LegalGround[] items;
      if (basisParam.length > 0)
        items = usecase.listGrounds(tenantId, basisParam.toLegalBasis);
      else if (purposeParam.length > 0)
        items = usecase.listGrounds(tenantId, purposeParam.toProcessingPurpose);
      else if (subjectParam.length > 0)
        items = usecase.listGrounds(tenantId, DataSubjectId(subjectParam));
      else
        items = usecase.listGrounds(tenantId);

      auto arr = items.map!(e => e.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", items.length)
        .set("message", "Legal grounds retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = LegalGroundId(precheck.id);

      auto entry = usecase.getGround(tenantId, id);
      if (entry.isNull) {
        writeError(res, 404, "Legal ground not found");
        return;
      }
      res.writeJsonBody(entry.toJson, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      UpdateLegalGroundRequest r;
      r.id = LegalGroundId(precheck.id);
      r.tenantId = tenantId;
      r.description = data.getString("description");
      r.legalReference = data.getString("legalReference");
      r.isActive = data.getBoolean("isActive", true);
      r.validUntil = data.getLong("validUntil");

      auto result = usecase.updateGround(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Legal ground updated successfully");

        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = LegalGroundId(precheck.id);

      usecase.deleteGround(tenantId, id);
      res.writeJsonBody(Json.emptyObject, 204);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }
}
