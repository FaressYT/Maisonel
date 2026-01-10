import 'package:flutter/material.dart';
import 'package:maisonel_v02/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/property.dart';
import '../../cubits/order/order_cubit.dart';
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
  Set<String> _unavailableDates = {};

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
  void initState() {
    super.initState();
    _loadUnavailableDates();
  }

  Future<void> _loadUnavailableDates() async {
    final dates = await context.read<OrderCubit>().getUnavailableDates(
      widget.property.id,
    );
    if (!mounted) return;
    setState(() {
      _unavailableDates = dates.map(_dateKey).toSet();
    });
  }

  String _dateKey(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  bool _isDateUnavailable(DateTime date) {
    return _unavailableDates.contains(_dateKey(date));
  }

  bool _rangeHasUnavailableDates(DateTime start, DateTime endExclusive) {
    var day = DateTime(start.year, start.month, start.day);
    final end = DateTime(endExclusive.year, endExclusive.month, endExclusive.day);
    while (day.isBefore(end)) {
      if (_isDateUnavailable(day)) return true;
      day = day.add(const Duration(days: 1));
    }
    return false;
  }

  bool _isMonthlyRangeAvailable(DateTime start, int months) {
    final end = DateTime(start.year, start.month + months, start.day);
    return !_rangeHasUnavailableDates(start, end);
  }

  int _maxAvailableMonthsFrom(DateTime start) {
    for (var months = 1; months <= 12; months++) {
      if (!_isMonthlyRangeAvailable(start, months)) return months - 1;
    }
    return 12;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.bookApartment)),
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
                Expanded(
                  child: _buildToggleOption(
                    AppLocalizations.of(context)!.daily,
                    !isMonthly,
                  ),
                ),
                Expanded(
                  child: _buildToggleOption(
                    AppLocalizations.of(context)!.monthly,
                    isMonthly,
                  ),
                ),
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
                    isMonthly
                        ? AppLocalizations.of(context)!.selectDuration
                        : AppLocalizations.of(context)!.selectDates,
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
                          AppLocalizations.of(context)!.rate,
                          isMonthly
                              ? '\$${widget.property.price.toInt()}${AppLocalizations.of(context)!.perMonthSuffix}'
                              : '\$${(widget.property.price / 30).toStringAsFixed(0)}${AppLocalizations.of(context)!.perDaySuffix}',
                        ),
                        const Divider(),
                        if (isMonthly)
                          _buildSummaryRow(
                            AppLocalizations.of(context)!.duration,
                            AppLocalizations.of(
                              context,
                            )!.monthsCount(monthsDuration),
                          )
                        else
                          _buildSummaryRow(
                            AppLocalizations.of(context)!.duration,
                            AppLocalizations.of(context)!.daysCount(
                              selectedDateRange?.duration.inDays ?? 0,
                            ),
                          ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.total,
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
                    ? () async {
                        // Prepare booking data
                        final checkIn = isMonthly
                            ? startMonth!
                            : selectedDateRange!.start;
                        final checkOut = isMonthly
                            ? DateTime(
                                startMonth!.year,
                                startMonth!.month + monthsDuration,
                                startMonth!.day,
                              )
                            : selectedDateRange!.end;

                        final pricePerNight = isMonthly
                            ? (widget.property.price / 30)
                            : (widget.property.price / 30);

                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (c) =>
                              const Center(child: CircularProgressIndicator()),
                        );

                        await context.read<OrderCubit>().createOrder(
                          apartmentId: widget.property.id,
                          guestCount: 1, // Defaulting to 1
                          checkInDate: checkIn,
                          checkOutDate: checkOut,
                          pricePerNight: pricePerNight,
                          totalCost: totalPrice,
                        );

                        if (!context.mounted) return;
                        Navigator.pop(context); // Pop loading

                        final state = context.read<OrderCubit>().state;
                        // Check for error state
                        if (state is OrderError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppLocalizations.of(
                                  context,
                                )!.bookingFailed(state.message),
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } else {
                          // Success (OrderLoaded or updated)
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppLocalizations.of(context)!.bookingSuccess,
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                          Navigator.popUntil(context, (route) => route.isFirst);
                        }
                      }
                    : null,
                child: Text(AppLocalizations.of(context)!.confirmBooking),
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
          isMonthly = title == AppLocalizations.of(context)!.monthly;
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
            final picked = await showDialog<DateTimeRange>(
              context: context,
              builder: (context) {
                return DateRangePickerDialog(
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  initialDateRange: selectedDateRange,
                  selectableDayPredicate: (day, start, end) =>
                      !_isDateUnavailable(day),
                );
              },
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
                      ? AppLocalizations.of(context)!.selectDates
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
        Text(AppLocalizations.of(context)!.startDate),
        const SizedBox(height: AppSpacing.sm),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              initialDate: startMonth ?? DateTime.now(),
              selectableDayPredicate: (day) => !_isDateUnavailable(day),
            );
            if (picked != null) {
              final maxAllowed = _maxAvailableMonthsFrom(picked);
              if (maxAllowed < 1) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(context)!.dateUnavailable,
                    ),
                  ),
                );
                return;
              }
              setState(() {
                startMonth = picked;
                if (monthsDuration > maxAllowed) {
                  monthsDuration = maxAllowed;
                }
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
                      ? AppLocalizations.of(context)!.selectStartDate
                      : startMonth!.toString().split(' ')[0],
                ),
                const Icon(Icons.calendar_today),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(AppLocalizations.of(context)!.monthsDurationLabel),
        Slider(
          value: monthsDuration.toDouble(),
          min: 1,
          max: 12,
          divisions: 11,
          label: AppLocalizations.of(context)!.monthsCount(monthsDuration),
          onChanged: (val) {
            setState(() {
              final nextDuration = val.round();
              if (startMonth == null) {
                monthsDuration = nextDuration;
                return;
              }
              final maxAllowed = _maxAvailableMonthsFrom(startMonth!);
              monthsDuration =
                  nextDuration <= maxAllowed ? nextDuration : maxAllowed;
            });
          },
        ),
        Center(
          child: Text(
            AppLocalizations.of(context)!.monthsCount(monthsDuration),
          ),
        ),
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
