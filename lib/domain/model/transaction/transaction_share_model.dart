import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class TransactionShare {
  static Future<void> shareTransaction({
    required String id,
    required String type,
    required String currency,
    required double amount,
    required DateTime date,
    required String status,
    required BuildContext context,
  }) async {
    try {
      final formattedDate = DateFormat('MMMM d, yyyy hh:mm a').format(date);

      final shareText = '''
🧾 Transaction Details
───────────────
ID: $id
Type: ${type.toUpperCase()}
Amount: $currency${amount.toStringAsFixed(2)}
Date: $formattedDate
Status: ${status.toUpperCase()}

Shared via Zippy App 💫
''';

      await Share.share(
        shareText,
        subject: 'Transaction Details from Zippy',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction details shared successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } on PlatformException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share: ${e.message}'),
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
