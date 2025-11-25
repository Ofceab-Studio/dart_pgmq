import 'dart:convert';

/// A fluent API for building conditional filters for pgmq read operations.
///
/// Example usage:
/// ```dart
/// // Simple equality filter
/// Filter.eq('status', 'pending')
///
/// // Comparison filters
/// Filter.gt('age', 18)
/// Filter.lt('score', 100)
/// Filter.gte('priority', 5)
///
/// // Check if field exists
/// Filter.exists('priority')
/// ```
class Filter {
  final String field;
  final String operator;
  final dynamic value;
  const Filter._({
    required this.field,
    required this.operator,
    required this.value,
  });

  /// Creates an equality filter: field = value
  ///
  /// Example: `Filter.eq('status', 'pending')`
  factory Filter.eq(String field, dynamic value) {
    return Filter._(field: field, operator: '=', value: value);
  }

  /// Creates a not-equal filter: field != value
  ///
  /// Example: `Filter.ne('status', 'archived')`
  factory Filter.ne(String field, dynamic value) {
    return Filter._(field: field, operator: '!=', value: value);
  }

  /// Creates a greater-than filter: field > value
  ///
  /// Example: `Filter.gt('age', 18)`
  factory Filter.gt(String field, dynamic value) {
    return Filter._(field: field, operator: '>', value: value);
  }

  /// Creates a greater-than-or-equal filter: field >= value
  ///
  /// Example: `Filter.gte('score', 80)`
  factory Filter.gte(String field, dynamic value) {
    return Filter._(field: field, operator: '>=', value: value);
  }

  /// Creates a less-than filter: field < value
  ///
  /// Example: `Filter.lt('age', 65)`
  factory Filter.lt(String field, dynamic value) {
    return Filter._(field: field, operator: '<', value: value);
  }

  /// Creates a less-than-or-equal filter: field <= value
  ///
  /// Example: `Filter.lte('priority', 10)`
  factory Filter.lte(String field, dynamic value) {
    return Filter._(field: field, operator: '<=', value: value);
  }

  /// Creates an exists filter: checks if field exists
  ///
  /// Example: `Filter.exists('priority')`
  factory Filter.exists(String field) {
    return Filter._(field: field, operator: 'exists', value: null);
  }

  /// Builds the filter into a Map that can be used in pgmq queries.
  ///
  /// If multiple conditions are chained, it creates a compound filter structure.
  Map<String, dynamic> build() => {
        'field': field,
        'operator': operator,
        if (value != null) 'value': value,
      };

  /// Converts the filter to JSON string format expected by pgmq.
  ///
  /// This is a convenience method that calls [build] and converts to JSON.
  @override
  String toString() {
    // For compound conditions, return the compound format
    return json.encode(build());
  }
}
