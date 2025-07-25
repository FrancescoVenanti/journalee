import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

enum ButtonVariant { primary, secondary, outline, text }

enum ButtonSize { small, medium, large }

class CustomButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? leftIcon;
  final IconData? rightIcon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const CustomButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = true,
    this.leftIcon,
    this.rightIcon,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: _getHeight(),
      child: _buildButton(context, isDark),
    );
  }

  Widget _buildButton(BuildContext context, bool isDark) {
    switch (variant) {
      case ButtonVariant.primary:
        return _buildElevatedButton(context, isDark);
      case ButtonVariant.secondary:
        return _buildSecondaryButton(context, isDark);
      case ButtonVariant.outline:
        return _buildOutlinedButton(context, isDark);
      case ButtonVariant.text:
        return _buildTextButton(context, isDark);
    }
  }

  Widget _buildElevatedButton(BuildContext context, bool isDark) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppColors.accent,
        foregroundColor: foregroundColor ?? AppColors.onPrimary,
        padding: padding ?? _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(12),
        ),
        textStyle: _getTextStyle(),
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildSecondaryButton(BuildContext context, bool isDark) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ??
            (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
        foregroundColor: foregroundColor ??
            (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
        padding: padding ?? _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(12),
          side: BorderSide(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          ),
        ),
        textStyle: _getTextStyle(),
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildOutlinedButton(BuildContext context, bool isDark) {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: foregroundColor ?? AppColors.accent,
        padding: padding ?? _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(12),
        ),
        side: BorderSide(
          color: backgroundColor ?? AppColors.accent,
        ),
        textStyle: _getTextStyle(),
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildTextButton(BuildContext context, bool isDark) {
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: foregroundColor ?? AppColors.accent,
        padding: padding ?? _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(12),
        ),
        textStyle: _getTextStyle(),
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildButtonContent() {
    if (isLoading) {
      return SizedBox(
        height: _getIconSize(),
        width: _getIconSize(),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            variant == ButtonVariant.primary
                ? AppColors.onPrimary
                : AppColors.accent,
          ),
        ),
      );
    }

    final widgets = <Widget>[];

    if (leftIcon != null) {
      widgets.add(Icon(leftIcon, size: _getIconSize()));
      widgets.add(SizedBox(width: _getIconSpacing()));
    }

    widgets.add(Flexible(child: child));

    if (rightIcon != null) {
      widgets.add(SizedBox(width: _getIconSpacing()));
      widgets.add(Icon(rightIcon, size: _getIconSize()));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: widgets,
    );
  }

  double _getHeight() {
    switch (size) {
      case ButtonSize.small:
        return 36;
      case ButtonSize.medium:
        return 48;
      case ButtonSize.large:
        return 56;
    }
  }

  EdgeInsetsGeometry _getPadding() {
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case ButtonSize.small:
        return AppTextStyles.buttonSmall;
      case ButtonSize.medium:
        return AppTextStyles.buttonMedium;
      case ButtonSize.large:
        return AppTextStyles.buttonLarge;
    }
  }

  double _getIconSize() {
    switch (size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.large:
        return 24;
    }
  }

  double _getIconSpacing() {
    switch (size) {
      case ButtonSize.small:
        return 6;
      case ButtonSize.medium:
        return 8;
      case ButtonSize.large:
        return 10;
    }
  }
}

// Factory constructors for common button types
extension CustomButtonFactories on CustomButton {
  static CustomButton primary({
    Key? key,
    required VoidCallback? onPressed,
    required Widget child,
    ButtonSize size = ButtonSize.medium,
    bool isLoading = false,
    bool isFullWidth = true,
    IconData? leftIcon,
    IconData? rightIcon,
  }) {
    return CustomButton(
      key: key,
      onPressed: onPressed,
      variant: ButtonVariant.primary,
      size: size,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
      leftIcon: leftIcon,
      rightIcon: rightIcon,
      child: child,
    );
  }

  static CustomButton secondary({
    Key? key,
    required VoidCallback? onPressed,
    required Widget child,
    ButtonSize size = ButtonSize.medium,
    bool isLoading = false,
    bool isFullWidth = true,
    IconData? leftIcon,
    IconData? rightIcon,
  }) {
    return CustomButton(
      key: key,
      onPressed: onPressed,
      variant: ButtonVariant.secondary,
      size: size,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
      leftIcon: leftIcon,
      rightIcon: rightIcon,
      child: child,
    );
  }

  static CustomButton outline({
    Key? key,
    required VoidCallback? onPressed,
    required Widget child,
    ButtonSize size = ButtonSize.medium,
    bool isLoading = false,
    bool isFullWidth = true,
    IconData? leftIcon,
    IconData? rightIcon,
  }) {
    return CustomButton(
      key: key,
      onPressed: onPressed,
      variant: ButtonVariant.outline,
      size: size,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
      leftIcon: leftIcon,
      rightIcon: rightIcon,
      child: child,
    );
  }
}
