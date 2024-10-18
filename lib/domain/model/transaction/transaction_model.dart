import 'dart:math';

class Transaction {
  final String id;
  final String title;
  final DateTime date;
  final String status;
  final String currency;
  final String type;
  final double amount;

  Transaction({
    required this.id,
    required this.title,
    required this.date,
    required this.status,
    required this.currency,
    required this.type,
    required this.amount,});

    static DateTime generateRandomDate() {
      final Random random = Random();
      int daysBack = random.nextInt(730);
      return DateTime.now().subtract(Duration(days: daysBack));
    }

    static String getRandomType() {
      final Random random = Random();
      final types = ['in', 'out'];
      return types[random.nextInt(types.length)];
    }

    static String getRandomTime() {
      final Random random = Random();
      final hour = random.nextInt(12) + 1;
      final minute = random.nextInt(60);
      final ampm = random.nextBool() ? 'AM' : 'PM';
      return '$hour:${minute.toString().padLeft(2, '0')} $ampm';
    }

    static double getRandomAmount() {
      final Random random = Random();
      return (random.nextDouble() * 10000).roundToDouble(); // Случайная сумма
    }

    static String getRandomStatus() {
      final Random random = Random();
      final statuses = ['pending', 'success', 'error'];
      return statuses[random.nextInt(statuses.length)];
    }

    static String getRandomId() {
      final Random random = Random();
      return '#${random.nextInt(1000000000)}'; // Случайный ID
    }

    static Transaction generateRandomTransaction()
    {
      return Transaction(
        id: getRandomId(),
        title: 'Transaction name',
        date: generateRandomDate(),
        currency: '\$',
        status: getRandomStatus(),
        amount: getRandomAmount(),
        type: getRandomType(),
      );
    }
}