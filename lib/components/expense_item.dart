import 'package:flutter/material.dart';
import 'package:notebash_app/models/expense.dart';
import 'package:notebash_app/utils/helpers.dart';

class ExpenseItem extends StatelessWidget {
  final void Function() onTap;
  final Expense expense;

  const ExpenseItem({super.key, required this.onTap, required this.expense});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).hoverColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(expense.category),
                  ),
                ),
                Text(formatAmount(expense.amount)),
              ],
            )),
      ),
    );
  }
}
