// lib/presentation/events/transaction_events.dart
// Make sure to create this file if it doesn't exist

import 'dart:async';
import 'package:zippy/domain/model/transaction/transaction_model.dart';

enum TransactionEventType { created, updated, deleted, balanceChanged }

class TransactionEvent {
  final TransactionEventType type;
  final Transaction? transaction;
  final num? balance;

  TransactionEvent({
    required this.type,
    this.transaction,
    this.balance,
  });
}

class TransactionEventBus {
  static final TransactionEventBus _instance = TransactionEventBus._internal();

  factory TransactionEventBus() => _instance;

  TransactionEventBus._internal();

  final StreamController<TransactionEvent> _eventController =
      StreamController<TransactionEvent>.broadcast();

  Stream<TransactionEvent> get events => _eventController.stream;

  void fire(TransactionEvent event) {
    _eventController.add(event);
  }

  void dispose() {
    _eventController.close();
  }
}
