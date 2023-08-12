enum AppRoutes {
  home("/home"),
  getStarted("/get-started"),
  signUp("/sign-up"),
  onboarding("/onboarding"),
  otpVerify("/otp-verify");

  const AppRoutes(this.route);
  final String route;
}
