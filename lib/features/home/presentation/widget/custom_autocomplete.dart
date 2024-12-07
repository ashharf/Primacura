import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../theme/provider/theme_provider.dart';

class CustomSearchableDropdown<T> extends StatefulWidget {
  final TextEditingController textEditingController;
  final List<T> items;
  final Iterable<T> Function(String searchQuery, Iterable<T> items) searchLogic;
  final String Function(T item)? displayText;
  final Widget Function(BuildContext context, T item)? itemBuilder;
  final Widget? Function(BuildContext context, T item)? subtitleBuilder;
  final Widget Function(BuildContext)? noSuggestionsBuilder;
  final void Function(T item)? onItemSelected;
  final void Function(T item)? onDelete;
  final void Function(String searchText)? onAddSelected;
  final Future<bool> Function(T item)? deleteConfirmationWidget;
  final Function(T item)? showItemDeleteButton;
  final String? hintText;
  final Widget? prefixIcon;
  final TextInputAction? textInputAction;
  final TextCapitalization? textCapitalization;
  final bool shouldHideDropdownOnSelect;
  final bool shouldUnFocusOnSelect;
  final bool shouldSelectAllTextOnTextFieldTap;
  final Function()? onTap;
  final FocusNode? focusNode;

  const CustomSearchableDropdown({
    super.key,
    required this.textEditingController,
    required this.items,
    required this.searchLogic,
    this.displayText,
    this.itemBuilder,
    this.subtitleBuilder,
    this.noSuggestionsBuilder,
    this.onItemSelected,
    this.onDelete,
    this.onAddSelected,
    this.deleteConfirmationWidget,
    this.showItemDeleteButton,
    this.hintText,
    this.prefixIcon,
    this.textInputAction,
    this.textCapitalization,
    this.shouldHideDropdownOnSelect = true,
    this.shouldUnFocusOnSelect = true,
    this.shouldSelectAllTextOnTextFieldTap = false,
    this.onTap,
    this.focusNode,
  });

  @override
  State<CustomSearchableDropdown> createState() => _CustomSearchableDropdownState<T>();
}

class _CustomSearchableDropdownState<T> extends State<CustomSearchableDropdown<T>> with WidgetsBindingObserver {
  List<T> filteredOptions = [];
  OverlayEntry? _overlayEntry;
  bool hasNoSuggestions = false;
  String query = '';
  T? selectedOption;

  final GlobalKey _textFieldKey = GlobalKey();
  final FocusNode _focusNode = FocusNode();
  ScrollController? _scrollController;

  @override
  void initState() {
    super.initState();
    filteredOptions = widget.items;

    // Listen for widget tree changes like screen navigation
    WidgetsBinding.instance.addObserver(this);

    // Close dropdown when TextField loses focus
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _hideDropdown();
      }
    });

    // Find the closest Scrollable widget and listen to its scroll events
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final scrollablePosition = Scrollable.of(context).position;

      scrollablePosition.addListener(_updateOverlayPosition);
    });
  }

  void _updateOverlayPosition() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
    }
  }

  void _filterOptions(String query) {
    setState(() {
      this.query = query;
      filteredOptions = widget.searchLogic(query, widget.items).toList();
      hasNoSuggestions = filteredOptions.isEmpty;
    });

    if (_overlayEntry != null) {
      _overlayEntry!.markNeedsBuild();
    }
  }

  void _showDropdown() {
    if (_overlayEntry == null) {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
    } else {
      _overlayEntry!.markNeedsBuild();
    }
  }

  void _hideDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = _textFieldKey.currentContext!.findRenderObject() as RenderBox;
    Offset offset = renderBox.localToGlobal(Offset.zero);
    double textFieldHeight = renderBox.size.height;

    return OverlayEntry(
      builder: (context) {
        return Positioned(
          top: offset.dy + textFieldHeight - (_scrollController?.offset ?? 0),
          left: offset.dx,
          width: renderBox.size.width,
          child: Material(
            elevation: 4,
            color: context.read<ThemeProvider>().getCurrentThemeBrightness == Brightness.light
                ? AppTheme.lightBackgroundColor
                : AppTheme.darkBackgroundColor,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.textEditingController.text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: AppTheme.primaryColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      // tileColor: Colors.amber,
                      title: Text(
                        widget.textEditingController.text,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        "Add",
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.add),
                        color: AppTheme.primaryColor,
                      ),
                      onTap: () {
                        widget.onAddSelected?.call(widget.textEditingController.text);
                        if (widget.shouldHideDropdownOnSelect) _hideDropdown();
                        if (widget.shouldUnFocusOnSelect) _focusNode.unfocus();
                      },
                    ),
                  ),
                if (hasNoSuggestions)
                  widget.noSuggestionsBuilder?.call(context) ??
                      ListTile(
                        // tileColor: Colors.blue,
                        title: Text("Not found"),
                      )
                else
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 120),
                    child: Container(
                      alignment: Alignment.topCenter,
                      // color: Colors.red,
                      child: SingleChildScrollView(
                        child: Column(
                            // shrinkWrap: true,
                            // itemCount: filteredOptions.length,
                            // itemBuilder: (context, index) {

                            children: List.generate(filteredOptions.length, (index) {
                          final option = filteredOptions[index];

                          return ListTile(
                            // tileColor: Colors.brown,
                            title: Text(widget.displayText?.call(option) ?? option.toString()),
                            subtitle: widget.subtitleBuilder != null && widget.subtitleBuilder!(context, option) != null
                                ? widget.subtitleBuilder!(context, option)
                                : null,
                            trailing: widget.showItemDeleteButton?.call(option) ?? false
                                ? IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () async {
                                      if (widget.deleteConfirmationWidget != null) {
                                        widget.deleteConfirmationWidget!(option).then((value) {
                                          if (value) {
                                            widget.onDelete?.call(option);
                                            _filterOptions(query);
                                          }
                                        });
                                      } else {
                                        final bool shouldDelete = await showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: Text('Delete Confirmation'),
                                              content: Text(
                                                'Are you sure you want to delete ${widget.displayText?.call(option) ?? option.toString()}?',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop(false);
                                                  },
                                                  child: Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop(true);
                                                  },
                                                  child: Text('Delete'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                        if (shouldDelete) {
                                          widget.onDelete?.call(option);
                                          _filterOptions(query);
                                        }
                                      }
                                    },
                                  )
                                : null,
                            onTap: () {
                              if (widget.onItemSelected != null) {
                                widget.onItemSelected!(option);
                              }
                              if (widget.shouldHideDropdownOnSelect) _hideDropdown();
                              selectedOption = option;
                              if (widget.displayText != null) {
                                widget.textEditingController.text = widget.displayText!(option);
                              } else {
                                widget.textEditingController.text = option.toString();
                              }

                              if (widget.shouldUnFocusOnSelect) _focusNode.unfocus();
                            },
                          );
                        })
                            // },
                            ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: _textFieldKey,
      focusNode: widget.focusNode ?? _focusNode,
      controller: widget.textEditingController,
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization ?? TextCapitalization.none,
      onTap: () {
        widget.onTap?.call();
        if (widget.shouldSelectAllTextOnTextFieldTap) {
          if (widget.textEditingController.text.isNotEmpty) {
            // Select all text when user taps on the field
            widget.textEditingController.selection = TextSelection(
              baseOffset: 0,
              extentOffset: widget.textEditingController.text.length,
            );
          }
        }
      },
      onChanged: (value) {
        if (value.isEmpty) {
          _hideDropdown();
          return;
        }
        _filterOptions(value);
        _showDropdown();
      },
      decoration: InputDecoration(
        prefixIcon: widget.prefixIcon,
        hintText: widget.hintText ?? 'Search...',
        border: OutlineInputBorder(),
      ),
    );
  }

  @override
  void dispose() {
    _hideDropdown();
    WidgetsBinding.instance.removeObserver(this);
    _scrollController?.removeListener(_updateOverlayPosition);
    _focusNode.dispose();
    super.dispose();
  }
}
