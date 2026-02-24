enum PlanType {
  free,
  cloud,
  report;

  bool get isCloudOrAbove => this == PlanType.cloud || this == PlanType.report;
  bool get isReport => this == PlanType.report;
}
