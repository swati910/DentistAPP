import 'package:flutter/widgets.dart';
import '../constants/app_constants.dart';

enum DeviceScreenType {
  mobile,
  tablet,
  desktop,
}

class ResponsiveUtils {
  ResponsiveUtils._();

  static DeviceScreenType getDeviceType(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= AppConstants.laptopBreakpoint) {
      return DeviceScreenType.desktop;
    }
    if (width >= AppConstants.tabletBreakpoint) {
      return DeviceScreenType.tablet;
    }
    return DeviceScreenType.mobile;
  }

  static bool isSmallMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width <= AppConstants.smallMobileBreakpoint;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < AppConstants.tabletBreakpoint;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= AppConstants.tabletBreakpoint && width < AppConstants.laptopBreakpoint;
  }

  static bool isLaptop(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= AppConstants.laptopBreakpoint && width < AppConstants.desktopBreakpoint;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= AppConstants.laptopBreakpoint;

  static bool isLargeDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= AppConstants.largeDesktopBreakpoint;

  static double contentWidth(BuildContext context) => MediaQuery.sizeOf(context).width;

  static T valueByDevice<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    final type = getDeviceType(context);
    switch (type) {
      case DeviceScreenType.desktop:
        return desktop ?? tablet ?? mobile;
      case DeviceScreenType.tablet:
        return tablet ?? mobile;
      case DeviceScreenType.mobile:
        return mobile;
    }
  }
}
