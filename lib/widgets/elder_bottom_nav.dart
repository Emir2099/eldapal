import 'package:flutter/material.dart';

class ElderBottomNav extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool elderMode;

  const ElderBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.elderMode,
  }) : super(key: key);

  @override
  State<ElderBottomNav> createState() => _ElderBottomNavState();
}

class _ElderBottomNavState extends State<ElderBottomNav> {
  bool _isVertical = false;
  bool _isHovered = false;
  bool _isDragging = false;
  bool _didDrag = false;
  // Position relative to the top-left of the screen.
  Offset _position = Offset.zero;
  // Variables to support dragging.
  Offset? _dragStart;
  Offset? _startPosition;
  final double _dragThreshold = 2.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Set default position to bottom center (50 px above bottom).
    if (_position == Offset.zero) {
      final size = MediaQuery.of(context).size;
      final navWidth = _isVertical ? 65 : size.width * 0.7;
      final navHeight = _isVertical ? 200 : 65;
      _position = Offset((size.width - navWidth) / 2, size.height - navHeight - 50);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onPanStart: (details) {
            setState(() {
              _isDragging = true;
              _didDrag = false;
              _dragStart = details.globalPosition;
              _startPosition = _position;
            });
          },
          onPanUpdate: (details) {
            final delta = details.globalPosition - _dragStart!;
            if (delta.distance > _dragThreshold) {
              _didDrag = true;
            }
            setState(() {
              _position = _startPosition! + delta;
              _clampPosition();
            });
          },
          onPanEnd: (details) {
            setState(() {
              _isDragging = false;
            });
            if (!_didDrag) {
              _showOptions(context);
            }
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(16),
                child: Container(
                  height: _isVertical ? 200 : 65,
                  width: _isVertical ? 65 : MediaQuery.of(context).size.width * 0.7,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(_isDragging ? 0.2 : 0.1),
                        blurRadius: _isDragging ? 20 : 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: _isVertical
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: _buildNavItems(context),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: _buildNavItems(context),
                        ),
                ),
              ),
              // When hovered, show overlay options above the nav bar.
              if (_isHovered)
                Positioned(
                  right: 0,
                  top: -45,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(_isVertical ? Icons.horizontal_distribute : Icons.vertical_distribute),
                          tooltip: _isVertical ? 'Make Horizontal' : 'Make Vertical',
                          onPressed: () => setState(() => _isVertical = !_isVertical),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          tooltip: 'Reset Position',
                          onPressed: () => _resetPosition(context),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildNavItems(BuildContext context) {
    return [
      _buildNavItem(context, 0, Icons.home_rounded),
      _buildNavItem(context, 1, Icons.people_alt_rounded),
      _buildNavItem(context, 2, Icons.settings_rounded),
    ];
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon) {
    final isSelected = widget.currentIndex == index;
    return GestureDetector(
      onTap: () => widget.onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: isSelected ? 40 : 0,
              width: isSelected ? 40 : 0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.2) : Colors.transparent,
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.only(bottom: isSelected ? 4 : 0),
              child: Icon(
                icon,
                size: isSelected ? 28 : 24,
                color: isSelected ? Theme.of(context).primaryColor : Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _resetPosition(BuildContext context) {
    setState(() {
      _isVertical = false;
      final size = MediaQuery.of(context).size;
      final navWidth = size.width * 0.7;
      const navHeight = 65;
      _position = Offset((size.width - navWidth) / 2, size.height - navHeight - 50);
    });
  }

  void _clampPosition() {
    final size = MediaQuery.of(context).size;
    final navWidth = _isVertical ? 65 : size.width * 0.7;
    final navHeight = _isVertical ? 200 : 65;
    double dx = _position.dx;
    double dy = _position.dy;
    if (dx < 0) dx = 0;
    if (dx > size.width - navWidth) dx = size.width - navWidth;
    if (dy < 0) dy = 0;
    if (dy > size.height - navHeight) dy = size.height - navHeight;
    _position = Offset(dx, dy);
  }

  void _showOptions(BuildContext context) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy - 100,
        position.dx + 100,
        position.dy,
      ),
      items: [
        PopupMenuItem(
          child: ListTile(
            leading: Icon(_isVertical ? Icons.horizontal_distribute : Icons.vertical_distribute),
            title: Text(_isVertical ? 'Make Horizontal' : 'Make Vertical'),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _isVertical = !_isVertical;
              });
            },
          ),
        ),
        PopupMenuItem(
          child: ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('Reset Position'),
            onTap: () {
              Navigator.pop(context);
              _resetPosition(context);
            },
          ),
        ),
      ],
    );
  }
}
