module uim.platform.service.application.dto;

import uim.platform.service;

mixin(ShowModule!());
@safe:
struct CommandResult {
  bool success;
  string id;
  string message;
  size_t errorCode;
  
  this(bool success, string id = "", string message = "", size_t errorCode = 0) {
    this.success = success;
    this.id = id;
    this.message = message;
    this.errorCode = errorCode;
  }

  bool isSuccess() const {
    return success;
  }

  bool hasError() const {
    return !success && message.length > 0;
  }

  string errorMessage() const {
    return hasError ? message : "";
  }

  Json toJson() const {
    return Json.emptyObject
        .set("success", success)
        .set("id", id)
        .set("message", message)
        .set("errorCode", errorCode);
  }
}
///
unittest {
  import std.stdio;

  CommandResult r1 = CommandResult(true, "123", "");
  assert(r1.isSuccess);
  assert(!r1.hasError);
  assert(r1.id == "123");
  assert(r1.message == "");

  CommandResult r2 = CommandResult(false, "", "Something went wrong");
  assert(!r2.isSuccess);
  assert(r2.hasError);
  assert(r2.id == "");
  assert(r2.message == "Something went wrong");
}
