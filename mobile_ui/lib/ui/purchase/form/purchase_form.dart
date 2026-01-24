import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_ui/providers/category_list_provider.dart';
import 'package:mobile_ui/providers/purchase_new_provider.dart';
import 'package:mobile_ui/ui/shared/app_divider_widget.dart';
import 'package:mobile_ui/ui/shared/snack_bar_widget.dart';

class PurchaseForm extends ConsumerStatefulWidget {
  const PurchaseForm({super.key});

  @override
  createState() => _PurchaseForm();
}

class _PurchaseForm extends ConsumerState<PurchaseForm> {
  final _formKey = GlobalKey<FormState>();
  final _costController = TextEditingController();
  final _titleController = TextEditingController();

  String? dropdownformfieldValue;

  @override
  void dispose() {
    _costController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final state = Provider.of<PurcaseFormState>(context, listen: true);
    final categories = ref.watch(categoryListProvider);

    return Container(
      padding: EdgeInsets.all(25),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // >> Enter a cost {{{
            TextFormField(
              controller: _titleController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter a cost',
                labelText: 'Cost',
                prefixIcon: Icon(Icons.currency_yen),
                border: InputBorder.none,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a cost';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a numeric';
                }
                return null;
              },
              onChanged: (numberString) {
                ref
                    .read(purchaseNewProvider.notifier)
                    .changeCost(double.parse(numberString));
              },
            ),
            // }}}
            SizedBox(height: 20),
            // >> Enter a title {{{
            TextFormField(
              controller: _costController,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'Enter a title',
                labelText: 'Title',
                prefixIcon: Icon(Icons.shopping_bag),
                border: InputBorder.none,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some title';
                }
                return null;
              },
              onChanged: (text) {
                ref.read(purchaseNewProvider.notifier).changeTitle(text);
              },
            ),
            // }}}
            AppDividerWidget(),
            SizedBox(height: 20),
            // >> Category selector {{{
            DropdownButtonFormField(
              initialValue: dropdownformfieldValue,
              decoration: InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category),
                border: InputBorder.none,
              ),
              items: categories.map((category) {
                return DropdownMenuItem(
                  value: category.id.toString(),
                  child: Text(category.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  dropdownformfieldValue = value;
                });
              },
            ),
            // }}}
            SizedBox(height: 40),
            // >> Submit button {{{
            ElevatedButton(
              onPressed: () {
                if (!_formKey.currentState!.validate()) return;
                final categoryId = dropdownformfieldValue != null
                    ? int.parse(dropdownformfieldValue!)
                    : null;
                ref
                    .read(purchaseNewProvider.notifier)
                    .add(categoryId: categoryId)
                    .then((v) {
                      ref.read(purchaseNewProvider.notifier).reset();
                      _costController.clear();
                      _titleController.clear();
                      setState(() {
                        dropdownformfieldValue = null;
                      });
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        getSnackBar(
                          context: context,
                          text: 'Success to add purchase',
                        ),
                      );
                    })
                    .catchError((err) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        getSnackBar(
                          context: context,
                          text: err.toString(),
                          error: true,
                        ),
                      );
                    });
              },
              style: ElevatedButton.styleFrom(fixedSize: Size(100, 100)),
              child: const Text('Submit'),
            ),
            // }}}
          ],
        ),
      ),
    );
  }
}

// vim:set foldmethod=marker:
