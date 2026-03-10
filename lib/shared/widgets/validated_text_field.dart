import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';

/// A reusable text field with real-time inline validation feedback.
///
/// Features:
/// - Focus-aware border colors (grey → purple → red on error → green on valid)
/// - Inline error text below the field
/// - Suffix icon: green checkmark when valid, red X on error
/// - Optional label above the field
class ValidatedTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String? label;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final bool obscureText;
  final Widget? prefix;
  final bool validateOnType;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;

  const ValidatedTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.label,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.maxLength,
    this.obscureText = false,
    this.prefix,
    this.validateOnType = true,
    this.focusNode,
    this.onChanged,
  });

  @override
  State<ValidatedTextField> createState() => _ValidatedTextFieldState();
}

class _ValidatedTextFieldState extends State<ValidatedTextField> {
  static const _primary = Color(0xFF6C63FF);
  static const _green = Color(0xFF4CAF50);
  static const _red = Color(0xFFF44336);

  late FocusNode _focusNode;
  bool _hasInteracted = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChanged);
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_onFocusChanged);
    }
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus && widget.controller.text.isNotEmpty) {
      _hasInteracted = true;
      _validate();
    }
    setState(() {});
  }

  void _onTextChanged() {
    widget.onChanged?.call(widget.controller.text);
    if (_hasInteracted || widget.controller.text.length > 2) {
      _hasInteracted = true;
      if (widget.validateOnType) _validate();
    }
  }

  void _validate() {
    if (widget.validator == null) return;
    setState(() {
      _errorText = widget.validator!(widget.controller.text);
    });
  }

  bool get _isValid =>
      _hasInteracted && _errorText == null && widget.controller.text.isNotEmpty;

  bool get _isError => _hasInteracted && _errorText != null;

  Color get _borderColor {
    if (_isError) return _red;
    if (_isValid) return _green;
    if (_focusNode.hasFocus) return _primary;
    return Colors.grey.shade300;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 6.h),
        ],
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: _borderColor, width: 1.5),
          ),
          child: Row(
            children: [
              if (widget.prefix != null) widget.prefix!,
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  keyboardType: widget.keyboardType,
                  inputFormatters: widget.inputFormatters,
                  maxLength: widget.maxLength,
                  obscureText: widget.obscureText,
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    counterText: "",
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                    suffixIcon: _buildSuffixIcon(),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Inline error text
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: _isError
              ? Padding(
                  padding: EdgeInsets.only(top: 6.h, left: 4.w),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: _red, size: 14.w),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          _errorText!,
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            color: _red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget? _buildSuffixIcon() {
    if (!_hasInteracted || widget.controller.text.isEmpty) return null;
    if (_isValid) {
      return Icon(Icons.check_circle, color: _green, size: 22.w);
    }
    if (_isError) {
      return Icon(Icons.cancel, color: _red, size: 22.w);
    }
    return null;
  }
}
