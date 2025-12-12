import 'package:flutter/material.dart';
import '../../models/property.dart';
import '../../theme.dart';

class BookingScreen extends StatefulWidget {
  final Property property;

  const BookingScreen({super.key, required this.property});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  bool isMonthly = false; // Toggle between Daily and Monthly
  DateTimeRange? selectedDateRange;
  DateTime? startMonth;
  int monthsDuration = 1;

  // Calculate total price
  double get totalPrice {
    if (isMonthly) {
      // Assuming property.price is monthly for simplicity in this context,
      // or if it's daily, we multiply by 30.
      // Based on Property model, price seems to be monthly context often ("$1500 / month" in UI)
      // Checks PropertyDetailsScreen UI: Text('\$${property.price.toInt()} / month')
      // So price is monthly.
      return widget.property.price * monthsDuration;
    } else {
      // If price is monthly, daily rate is price / 30.
      if (selectedDateRange == null) return 0;
      final days = selectedDateRange!.duration.inDays;
      return (widget.property.price / 30) * days;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Apartment')),
      body: Column(
        children: [
          // Toggle Switch
          Container(
            margin: const EdgeInsets.all(AppSpacing.md),
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Row(
              children: [
                Expanded(child: _buildToggleOption('Daily', !isMonthly)),
                Expanded(child: _buildToggleOption('Monthly', isMonthly)),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isMonthly ? 'Select Duration' : 'Select Dates',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  if (isMonthly)
                    _buildMonthlySelector()
                  else
                    _buildDailySelector(),

                  const SizedBox(height: AppSpacing.xl),

                  // Summary
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      boxShadow: AppShadows.small,
                      border: Border.all(
                        color: Theme.of(context).dividerColor.withOpacity(0.1),
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildSummaryRow(
                          'Rate',
                          isMonthly
                              ? '\$${widget.property.price.toInt()}/mo'
                              : '\$${(widget.property.price / 30).toStringAsFixed(0)}/day',
                        ),
                        const Divider(),
                        if (isMonthly)
                          _buildSummaryRow('Duration', '$monthsDuration months')
                        else
                          _buildSummaryRow(
                            'Duration',
                            '${selectedDateRange?.duration.inDays ?? 0} days',
                          ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '\$${totalPrice.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Book Button
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: AppShadows.large,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed:
                    (isMonthly && startMonth != null) ||
                        (!isMonthly && selectedDateRange != null)
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Booking request sent!'),
                          ),
                        );
                        // Navigate to success or home
                        Navigator.popUntil(context, (route) => route.isFirst);
                      }
                    : null,
                child: const Text('Confirm Booking'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleOption(String title, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isMonthly = title == 'Monthly';
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.surface
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.full),
          boxShadow: isSelected ? AppShadows.small : null,
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildDailySelector() {
    return Column(
      children: [
        InkWell(
          onTap: () async {
            final picked = await showDateRangePicker(
              context: context,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              initialDateRange: selectedDateRange,
            );
            if (picked != null) {
              setState(() {
                selectedDateRange = picked;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.md,
              horizontal: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).primaryColor),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDateRange == null
                      ? 'Select Dates'
                      : '${selectedDateRange!.start.toString().split(' ')[0]} - ${selectedDateRange!.end.toString().split(' ')[0]}',
                ),
                const Icon(Icons.calendar_today),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Start Date'),
        const SizedBox(height: AppSpacing.sm),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              initialDate: startMonth ?? DateTime.now(),
            );
            if (picked != null) {
              setState(() {
                startMonth = picked;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.md,
              horizontal: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  startMonth == null
                      ? 'Select Start Date'
                      : startMonth!.toString().split(' ')[0],
                ),
                const Icon(Icons.calendar_today),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const Text('Duration (Months)'),
        Slider(
          value: monthsDuration.toDouble(),
          min: 1,
          max: 12,
          divisions: 11,
          label: '$monthsDuration months',
          onChanged: (val) {
            setState(() {
              monthsDuration = val.round();
            });
          },
        ),
        Center(child: Text('$monthsDuration months')),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
