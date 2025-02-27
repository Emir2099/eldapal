import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateSelector extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;
  final bool elderMode;

  const DateSelector({
    required this.selectedDate,
    required this.onDateChanged,
    required this.elderMode,
  });

  @override
  _DateSelectorState createState() => _DateSelectorState();
}

class _DateSelectorState extends State<DateSelector> {
  final List<DateTime> _dates = [];
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeDates();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelectedDate());
  }

  void _initializeDates() {
    final today = DateTime.now();
    _dates.addAll(List.generate(14, (index) => today.add(Duration(days: index - 7))));
  }

  void _scrollToSelectedDate() {
    final index = _dates.indexWhere((date) => 
      date.year == widget.selectedDate.year &&
      date.month == widget.selectedDate.month &&
      date.day == widget.selectedDate.day
    );
    
    if (index != -1) {
      final offset = (index * (widget.elderMode ? 70.0 : 60.0)) - 
        MediaQuery.of(context).size.width / 2 +
        (widget.elderMode ? 35.0 : 30.0);
      
      _scrollController.animateTo(
        offset,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.elderMode ? 80 : 70,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: _dates.length,
        itemBuilder: (context, index) {
          final date = _dates[index];
          final isSelected = date.year == widget.selectedDate.year &&
              date.month == widget.selectedDate.month &&
              date.day == widget.selectedDate.day;
          final isToday = date.year == DateTime.now().year &&
              date.month == DateTime.now().month &&
              date.day == DateTime.now().day;

          return _DateItem(
            date: date,
            isSelected: isSelected,
            isToday: isToday,
            elderMode: widget.elderMode,
            onTap: () => widget.onDateChanged(date),
          );
        },
      ),
    );
  }
}

class _DateItem extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final bool isToday;
  final bool elderMode;
  final VoidCallback onTap;

  const _DateItem({
    required this.date,
    required this.isSelected,
    required this.isToday,
    required this.elderMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: elderMode ? 70 : 60,
        margin: EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isToday ? Border.all(color: Colors.blue, width: 2) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat('E').format(date),
              style: TextStyle(
                fontSize: elderMode ? 16 : 14,
                color: isSelected ? Colors.white : Colors.grey,
              ),
            ),
            SizedBox(height: 4),
            Text(
              date.day.toString(),
              style: TextStyle(
                fontSize: elderMode ? 24 : 20,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}