import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TransactionTile extends StatefulWidget {
  final String id;
  final String title;
  final String date;
  final String time;
  final String status;
  final String currency;
  final double amount;
  final VoidCallback onIconTap;

  const TransactionTile({
    Key? key,
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.onIconTap,
    required this.amount,
    required this.status,
    required this.currency,
  }) : super(key: key);

  @override
  _TransactionTileState createState() => _TransactionTileState();
}

class _TransactionTileState extends State<TransactionTile> {
  bool _isExpanded = false;

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleExpansion,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.tertiaryContainer,
          borderRadius: BorderRadius.zero,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text(
                widget.title, // Используем переданное название транзакции
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              subtitle: Text(
                widget.date+" "+widget.time, // Используем переданную подстроку
                style: Theme.of(context).textTheme.bodySmall,
              ),
              leading: SvgPicture.asset(
                'assets/images/icon_transaction_background.svg',
                height: 36.0,
                width: 36.0,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${widget.currency ?? ''}${widget.amount.toStringAsFixed(2)}', // Форматируем сумму с валютой
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  SizedBox(width: 8.0), // Добавляем немного отступа между текстом и иконкой
                  GestureDetector(
                    onTap: widget.onIconTap, // Вызываем переданный обработчик
                    child: SvgPicture.asset(
                      'assets/images/icon_receipt.svg', // Замените на путь к вашей иконке чека
                      height: 24.0, // Высота иконки
                      width: 24.0, // Ширина иконки
                    ),
                  ),
                ],
              ),
            ),
            if (_isExpanded)
              Container(
                padding: EdgeInsets.all(12),
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Распределяем пространство между колонками
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start, // Выравниваем по левому краю
                      children: [
                        Row(
                          children: [
                            Text(
                              'Transaction ID: ', // Замените на необходимую информацию
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              widget.id, // Замените на необходимую информацию
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              'Amount: ', // Замените на необходимую информацию
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              widget.currency! + widget.amount.toString(), // Замените на необходимую информацию
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              'Date: ', // Замените на необходимую информацию
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              widget.date, // Замените на необходимую информацию
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              'Time: ', // Замените на необходимую информацию
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              widget.time, // Замените на необходимую информацию
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end, // Выравниваем по правому краю
                      children: [
                        Text(
                          'Status: ' + widget.status, // Замените на необходимую информацию
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Column(
                              children: [
                                SvgPicture.asset(
                                  'assets/images/icon_support.svg',
                                  height: 24.0,
                                  width: 24.0,
                                ),
                                Text(
                                  'Help', // Замените на необходимую информацию
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            Column(
                              children: [
                                SvgPicture.asset(
                                  'assets/images/icon_copy.svg',
                                  height: 24.0,
                                  width: 24.0,
                                ),
                                Text(
                                  'Copy', // Замените на необходимую информацию
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            Column(
                              children: [
                                SvgPicture.asset(
                                  'assets/images/icon_share.svg',
                                  height: 24.0,
                                  width: 24.0,
                                ),
                                Text(
                                  'Share', // Замените на необходимую информацию
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ],
                            ),
                          ],
                        ),
                        
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}