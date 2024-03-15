class ActionResult<T> {
  bool success = true;
  String? message = '';
  T? data;

  ActionResult({required this.success, this.message, this.data});
}
