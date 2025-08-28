import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../../constants/tap_feedback_helpers.dart';

class CustomDropdown extends StatefulWidget {
  final List<String> items;
  final String selectedItem;
  final ValueChanged<String> onItemSelected;

  const CustomDropdown({
    Key? key,
    required this.items,
    required this.selectedItem,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  bool _isDropdownOpen = false;
  late String _currentSelected;
  final ScrollController _scrollController = ScrollController();

  static const double _kItemExtent = 48.0;

  @override
  void initState() {
    super.initState();
    _currentSelected = widget.selectedItem;
  }

  @override
  void didUpdateWidget(CustomDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedItem != oldWidget.selectedItem) {
      _currentSelected = widget.selectedItem;
    }
  }

  void _toggleDropdown() {
    if (_isDropdownOpen) {
      _closeDropdown();
    } else {
      FocusScope.of(context).unfocus();
      _openDropdown();
    }
  }

  void _openDropdown() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isDropdownOpen = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.minScrollExtent);
        _clampToEdges();
      }
    });
  }

  void _closeDropdown() {
    if (_isDropdownOpen && _overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
      setState(() {
        _isDropdownOpen = false;
      });
    }
  }

  void _clampToEdges() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    final min = pos.minScrollExtent;
    final max = pos.maxScrollExtent;
    final px = pos.pixels;

    const eps = 0.5;
    if ((px - min).abs() <= eps && px != min) {
      _scrollController.jumpTo(min);
    } else if ((px - max).abs() <= eps && px != max) {
      _scrollController.jumpTo(max);
    }
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    final int calculatedVisibleItems =
        widget.items.length < 4 ? widget.items.length : 4;
    final double calculatedDropdownHeight =
        _kItemExtent * calculatedVisibleItems;
    final bool shouldShowScrollbar =
        widget.items.length > calculatedVisibleItems;

    return OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _closeDropdown,
              ),
            ),
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0, size.height + 5),
              child: Material(
                color: Colors.transparent,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: size.width,
                    height: calculatedDropdownHeight,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFF7DF27),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF7DF27).withOpacity(0.4),
                          blurRadius: 12,
                          spreadRadius: 1,
                          offset: const Offset(0, 0),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.8),
                          blurRadius: 6,
                          spreadRadius: 2,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        scrollbarTheme: ScrollbarThemeData(
                          thumbColor: MaterialStateProperty.all(
                            const Color(0xFFF7DF27),
                          ),
                        ),
                      ),
                      child: RawScrollbar(
                        controller: _scrollController,
                        thumbVisibility: shouldShowScrollbar,
                        thumbColor: const Color(0xFFF7DF27),
                        radius: const Radius.circular(10),
                        thickness: 5,
                        interactive: true,
                        notificationPredicate: (n) => n.depth == 0,
                        child: NotificationListener<ScrollEndNotification>(
                          onNotification: (notification) {
                            _clampToEdges();
                            return false;
                          },
                          child: ListView.builder(
                            controller: _scrollController,
                            padding: EdgeInsets.zero,
                            primary: false,
                            dragStartBehavior: DragStartBehavior.down,
                            physics: const ClampingScrollPhysics(),
                            itemCount: widget.items.length,
                            itemExtent: _kItemExtent,
                            itemBuilder: (context, index) {
                              final item = widget.items[index];
                              final bool isSelected = item == _currentSelected;

                              return TapFeedbackHelpers.tapFeedbackContainer(
                                context: context,
                                onTap: () {
                                  setState(() {
                                    _currentSelected = item;
                                  });
                                  widget.onItemSelected(item);
                                  _closeDropdown();
                                },
                                backgroundColor: Colors.black,
                                foregroundColor: const Color(0xFFF7DF27).withOpacity(0.3),
                                child: Container(
                                  height: _kItemExtent,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  alignment: Alignment.centerLeft,
                                  decoration:
                                      isSelected
                                          ? BoxDecoration(
                                            color: const Color(
                                              0xFFF7DF27,
                                            ).withOpacity(0.1),
                                          )
                                          : null,
                                  child: Text(
                                    item,
                                    style: TextStyle(
                                      color:
                                          isSelected
                                              ? const Color(0xFFF7DF27)
                                              : Colors.white,
                                      fontWeight:
                                          isSelected
                                              ? FontWeight.w500
                                              : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _closeDropdown();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TapFeedbackHelpers.tapFeedbackContainer(
        context: context,
        onTap: _toggleDropdown,
        backgroundColor: Colors.white.withOpacity(0.05),
        foregroundColor: const Color(0xFFF7DF27).withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF7DF27), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF7DF27).withOpacity(0.4),
                blurRadius: 12,
                spreadRadius: 1,
                offset: const Offset(0, 0),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.8),
                blurRadius: 6,
                spreadRadius: 2,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _currentSelected,
                  style: const TextStyle(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Transform.rotate(
                angle: _isDropdownOpen ? 3.14159 : 0,
                child: const Icon(Icons.arrow_drop_down, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
