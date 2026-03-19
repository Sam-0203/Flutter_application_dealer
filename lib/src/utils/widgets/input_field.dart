import 'package:dealershub_/src/views/user/login.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

// Input Field - - - -
class UserInputField extends StatefulWidget {
  final TextEditingController? controller;
  final String hintText;
  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLength;
  final bool onlyDigits;
  final FocusNode focusNode;
  final List<IndianPhoneFormatter>? inputFormatters;

  const UserInputField({
    super.key,
    this.controller,
    required this.hintText,
    required this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLength,
    this.onlyDigits = false,
    required this.focusNode,
    List<IndianPhoneFormatter> this.inputFormatters = const [],
  });

  @override
  State<UserInputField> createState() => _UserInputFieldState();
}

class _UserInputFieldState extends State<UserInputField> {
  final FocusNode phoneFocus = FocusNode();

  void _closeKeyboard() {
    phoneFocus.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      maxLength: widget.maxLength,
      textInputAction: TextInputAction.done,
      onEditingComplete: _closeKeyboard,
      focusNode: widget.focusNode,
      inputFormatters: widget.onlyDigits
          ? [
              FilteringTextInputFormatter.digitsOnly,
              if (widget.maxLength != null)
                LengthLimitingTextInputFormatter(widget.maxLength),
            ]
          : null,
      decoration: InputDecoration(
        fillColor: Colors.white,
        hintText: widget.hintText,
        hintStyle: GoogleFonts.mulish(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Color.fromRGBO(59, 59, 59, 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        counterText: '',
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color.fromRGBO(190, 205, 255, 1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color.fromRGBO(190, 205, 255, 1)),
        ),
      ),
    );
  }
}

// Dropdown - - - -
class UserDropdownField<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final String hintText;
  final ValueChanged<T?> onChanged;
  final Color? fillColor;
  final EdgeInsetsGeometry? contentPadding;

  const UserDropdownField({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.hintText,
    this.fillColor,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    // Show items in a bottom sheet when tapped, preserving decoration
    final selectedLabel = value == null
        ? null
        : items
              .firstWhere(
                (e) => e.value == value,
                orElse: () => DropdownMenuItem<T>(
                  value: value,
                  child: Center(child: Text(value.toString())),
                ),
              )
              .child;

    return InkWell(
      onTap: () async {
        final picked = await showModalBottomSheet<T>(
          context: context,
          backgroundColor: const Color.fromRGBO(218, 218, 218, 1),
          builder: (context) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return ListTile(
                          title: item.child,
                          onTap: () {
                            Navigator.of(context).pop(item.value);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        isEmpty: value == null,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.mulish(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color.fromRGBO(59, 59, 59, 1),
          ),
          contentPadding:
              contentPadding ??
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          filled: fillColor != null,
          fillColor: fillColor,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color.fromRGBO(190, 205, 255, 1),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color.fromRGBO(190, 205, 255, 1),
            ),
          ),
          suffixIcon: const Icon(
            Icons.arrow_drop_down,
            color: Color(0xFF2C3E8F),
          ),
        ),
        child: value == null
            ? null
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: selectedLabel is Text
                        ? Text(
                            (selectedLabel).data ?? '',
                            style: GoogleFonts.mulish(fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          )
                        : Text(
                            value?.toString() ?? '',
                            style: GoogleFonts.mulish(fontSize: 16),
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}

// String? selectedRole;

// UserDropdownField<String>(
//   hintText: 'Select role',
//   value: selectedRole,
//   items: const [
//     DropdownMenuItem(value: 'Dealer', child: Text('Dealer')),
//     DropdownMenuItem(value: 'Agent', child: Text('Agent')),
//   ],
//   onChanged: (value) {
//     selectedRole = value;
//   },
// );
