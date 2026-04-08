module uim.platform.service.application.dto;

@safe:
struct CommandResult {
  string id;
  string error;
  // bool success;

  bool isSuccess() const {
    return error.length == 0;
  }
}


// struct CommandResult {
//   bool success;
//   string id;
//   string error;
// }
