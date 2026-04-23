import 'package:flutter/material.dart';
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
  final bool onlyLetters;
  final bool showClearIcon;
  final FocusNode focusNode;
  final List<TextInputFormatter>? inputFormatters;
  final EdgeInsets scrollPadding;

  const UserInputField({
    super.key,
    this.controller,
    required this.hintText,
    required this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLength,
    this.onlyDigits = false,
    this.onlyLetters = false,
    this.showClearIcon = false,
    required this.focusNode,
    this.inputFormatters = const [],
    this.scrollPadding = const EdgeInsets.all(20),
  });

  @override
  State<UserInputField> createState() => _UserInputFieldState();
}

class _UserInputFieldState extends State<UserInputField> {
  bool _showClear = false;

  void _closeKeyboard() {
    widget.focusNode.unfocus();
  }

  void _updateClearIcon() {
    if (!widget.showClearIcon) return;
    final hasText = widget.controller?.text.isNotEmpty ?? false;
    if (_showClear != hasText) {
      setState(() {
        _showClear = hasText;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.showClearIcon) {
      widget.controller?.addListener(_updateClearIcon);
    }
    _updateClearIcon();
  }

  @override
  void didUpdateWidget(covariant UserInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final controllerChanged = oldWidget.controller != widget.controller;
    final clearIconStateChanged =
        oldWidget.showClearIcon != widget.showClearIcon;

    if (controllerChanged || clearIconStateChanged) {
      if (oldWidget.showClearIcon) {
        oldWidget.controller?.removeListener(_updateClearIcon);
      }
      if (widget.showClearIcon) {
        widget.controller?.addListener(_updateClearIcon);
      }
      _updateClearIcon();
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_updateClearIcon);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      maxLength: widget.maxLength,
      scrollPadding: widget.scrollPadding,
      cursorColor: const Color.fromRGBO(41, 68, 135, 1),
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: const Color.fromRGBO(59, 59, 59, 1),
      ),
      textInputAction: TextInputAction.done,
      onEditingComplete: _closeKeyboard,
      focusNode: widget.focusNode,
      inputFormatters: widget.onlyDigits
          ? [
              FilteringTextInputFormatter.digitsOnly,
              if (widget.maxLength != null)
                LengthLimitingTextInputFormatter(widget.maxLength),
            ]
          : widget.onlyLetters
          ? [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
              if (widget.maxLength != null)
                LengthLimitingTextInputFormatter(widget.maxLength),
            ]
          : widget.inputFormatters,
      decoration: InputDecoration(
        fillColor: Colors.white,
        hintText: widget.hintText,
        hintStyle: TextStyle(
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
        suffixIcon: widget.showClearIcon && _showClear
            ? GestureDetector(
                onTap: () {
                  widget.controller?.clear();
                  _updateClearIcon();
                },
                child: const Icon(Icons.clear, color: Colors.black45, size: 20),
              )
            : widget.suffixIcon,
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
  final bool enableSearch;
  final String Function(T? value)? itemAsString;

  const UserDropdownField({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.hintText,
    this.fillColor,
    this.contentPadding,
    this.enableSearch = false,
    this.itemAsString,
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
    final selectedText = itemAsString != null
        ? itemAsString!(value)
        : (selectedLabel is Text
              ? selectedLabel.data ?? ''
              : value?.toString() ?? '');

    return InkWell(
      onTap: () async {
        final searchController = TextEditingController();

        final picked = await showModalBottomSheet<T>(
          context: context,
          isScrollControlled: true,
          backgroundColor: const Color.fromRGBO(218, 218, 218, 1),
          builder: (context) {
            return SafeArea(
              child: StatefulBuilder(
                builder: (context, setModalState) {
                  List<DropdownMenuItem<T>> filteredItems = items;

                  if (enableSearch) {
                    final query = searchController.text.trim().toLowerCase();
                    if (query.isNotEmpty) {
                      filteredItems = items.where((item) {
                        final text = itemAsString != null
                            ? itemAsString!(item.value)
                            : (item.child is Text
                                  ? (item.child as Text).data ?? ''
                                  : item.value?.toString() ?? '');
                        return text.toLowerCase().contains(query);
                      }).toList();
                    }
                  }

                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
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
                        if (enableSearch) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                            child: TextField(
                              controller: searchController,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search $hintText',
                                hintStyle: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black45,
                                ),
                                suffixIcon: searchController.text.isNotEmpty
                                    ? GestureDetector(
                                        onTap: () {
                                          searchController.clear();
                                          setModalState(() {});
                                        },
                                        child: const Icon(
                                          Icons.close,
                                          color: Color(0xFF8A93AB),
                                          size: 20,
                                        ),
                                      )
                                    : null,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFBECDFF),
                                    width: 1.4,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF2C3E8F),
                                    width: 1.6,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              onChanged: (_) => setModalState(() {}),
                            ),
                          ),
                        ],
                        Flexible(
                          child: filteredItems.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text('No results found.'),
                                )
                              : ListView.separated(
                                  shrinkWrap: true,
                                  itemCount: filteredItems.length,
                                  separatorBuilder: (_, __) =>
                                      const Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final item = filteredItems[index];
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
          hintStyle: TextStyle(
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
                            selectedText,
                            style: TextStyle(fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          )
                        : selectedLabel ??
                              Text(
                                selectedText,
                                style: TextStyle(fontSize: 16),
                              ),
                  ),
                ],
              ),
      ),
    );
  }
}
