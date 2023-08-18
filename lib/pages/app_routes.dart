enum AppRoutes {
  home("/home"),
  getStarted("/get-started"),
  profile("/profile"),
  newLoan("/new-loan"),
  enterPhone("/enter-phone"),
  onboarding("/onboarding"),
  otpVerify("/otp-verify");

  const AppRoutes(this.route);
  final String route;
}
