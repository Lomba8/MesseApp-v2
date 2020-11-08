library account_selector;

import 'package:account_selector/account.dart';
import 'single_account_selector.dart';
import 'package:flutter/material.dart';

showAccountSelectorSheet({
  @required BuildContext context,
  @required List<Account> accountList,
  int initiallySelectedIndex = -1,
  Future<void> Function(int id) tapCallback,
  Future<void> Function(int id) removeAccountTapCallback,
  bool hideSheetOnItemTap = false,
  Color selectedRadioColor = Colors.green,
  bool showAddAccountOption = false,
  Function addAccountTapCallback,
  String addAccountTitle = "Add Account",
  Color arrowColor = Colors.grey,
  Color backgroundColor = Colors.white,
  Color selectedTextColor = Colors.green,
  Color unselectedTextColor = const Color(0xFF424242),
  Color unselectedRadioColor = Colors.grey,
  bool isSheetDismissible = true,
  List<int> accountIds,
}) {
  List<AccountWithSelectionBoolean> accountwithselectionList =
      setupAccountWithSelectionList(
    accountList,
    initiallySelectedIndex,
    showAddAccountOption,
    addAccountTitle,
  );
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isDismissible: isSheetDismissible,
    isScrollControlled: true,
    builder: (context) {
      return SingleAccountSelectionWidget(
        accountwithselectionList: accountwithselectionList,
        initiallySelectedIndex: initiallySelectedIndex,
        tapCallback: tapCallback ?? (val) {},
        hideSheetOnItemTap: hideSheetOnItemTap,
        selectedRadioColor: selectedRadioColor,
        showAddAccountOption: showAddAccountOption,
        addAccountTapCallback: addAccountTapCallback ?? () {},
        arrowColor: arrowColor,
        backgroundColor: backgroundColor,
        selectedTextColor: selectedTextColor,
        unselectedTextColor: unselectedTextColor,
        unselectedRadioColor: unselectedRadioColor,
        removeAccountTapCallback: removeAccountTapCallback,
        accountIds: accountIds,
      );
    },
  );
}
