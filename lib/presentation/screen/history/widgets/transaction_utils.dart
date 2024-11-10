import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class TransactionUtils {
  static Future<void> copyTransactionDetails({
    required String id,
    required String type,
    required String currency,
    required double amount,
    required DateTime date,
    required String status,
    required BuildContext context,
  }) async {
    try {
      final formattedDate =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";

      final textToCopy = '''
Transaction Details
─────────────────
ID: $id
Type: ${type.toUpperCase()}
Amount: $currency${amount.toStringAsFixed(2)}
Date: $formattedDate
Status: ${status.toUpperCase()}
''';

      await Clipboard.setData(ClipboardData(text: textToCopy));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction details copied to clipboard! 📋'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } on PlatformException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to copy: ${e.message}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
