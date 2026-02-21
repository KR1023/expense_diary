import 'package:expense_diary/component/banner_ad_widget.dart';
import 'package:flutter/material.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:expense_diary/database/drift_database.dart';
import 'package:get_it/get_it.dart';
import 'package:expense_diary/component/common/app_background.dart';
import 'package:expense_diary/const/app_colors.dart';
import 'package:easy_localization/easy_localization.dart';

class CategoryScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CategoryScreenState();
}

class CategoryScreenState extends State<CategoryScreen> {
  String? _errorText = null;
  TextEditingController _inputCategoryController = TextEditingController();
  String _keyword = '';

  @override
  void initState() {
    super.initState();
    _inputCategoryController.addListener(() {
      setState(() {
        _keyword = _inputCategoryController.text;
      });
    });
  }

  @override
  void dispose() {
    _inputCategoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'category.manage_title'.tr(),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                FilledButton.tonalIcon(
                  onPressed: () {
                    _showInputDialog(context);
                  },
                  icon: Icon(Icons.add),
                  label: Text('common.add'.tr()),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _inputCategoryController,
              decoration: InputDecoration(
                hintText: 'category.search_hint'.tr(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
            SizedBox(height: 12),
            Expanded(
              child: StreamBuilder(
                stream: GetIt.I<LocalDatabase>().watchCategory(
                  _keyword.isEmpty ? null : _keyword,
                ),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.length == 0) {
                    return Center(
                      child: Text(
                        'category.empty'.tr(),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.mutedOf(context),
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: snapshot.data!.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final category = snapshot.data![index];

                      return InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          _showUpdateDialog(context, category);
                        },
                        child: Card(
                          margin: EdgeInsets.zero,
                          child: ListTile(
                            title: Text(category.categoryName),
                            trailing: IconButton(
                              icon: Icon(Icons.delete_outline),
                              onPressed: () async {
                                int count = await GetIt.I<LocalDatabase>()
                                    .countExpensesByCategory(category.id);
                                if (count > 0) {
                                  _showAlertDialog(
                                    context,
                                    'category.delete_blocked'.tr(),
                                  );
                                  return;
                                } else {
                                  GetIt.I<LocalDatabase>().deleteCategory(
                                    category.id,
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            BannerAdWidget(),
          ],
        ),
      ),
    );
  }

  Future<void> _showAlertDialog(BuildContext context, String message) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primary),
              SizedBox(width: 8),
              Text('category.alert_title'.tr()),
            ],
          ),
          content: Text(message),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('common.confirm'.tr()),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showInputDialog(BuildContext context) async {
    TextEditingController textController = TextEditingController();
    _errorText = null;

    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.label_outline, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text('category.input_title'.tr()),
                ],
              ),
              content: TextField(
                controller: textController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'category.input_hint'.tr(),
                  errorText: _errorText,
                ),
              ),
              actions: <Widget>[
                OutlinedButton(
                  child: Text('common.cancel'.tr()),
                  onPressed: () {
                    setState(() {
                      _errorText = null;
                    });
                    Navigator.of(context).pop();
                  },
                ),
                FilledButton(
                  child: Text('common.confirm'.tr()),
                  onPressed: () async {
                    try {
                      await GetIt.I<LocalDatabase>().addCategory(
                        CategoryCompanion(
                          categoryName: Value(textController.text),
                        ),
                      );
                      setState(() {
                        _errorText = null;
                      });
                    } catch (e) {
                      bool conflictName = e.toString().contains('2067');
                      if (conflictName) {
                        setState(() {
                          _errorText = 'category.duplicate_error'.tr();
                        });
                        return;
                      }
                    }

                    setState(() {
                      _errorText = null;
                    });

                    Navigator.of(context).pop(textController.text);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showUpdateDialog(
    BuildContext context,
    CategoryData category,
  ) async {
    TextEditingController textController = TextEditingController();
    textController.text = category.categoryName;
    _errorText = null;

    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.edit_outlined, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text('category.edit_title'.tr()),
                ],
              ),
              content: TextField(
                controller: textController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'category.edit_hint'.tr(),
                  errorText: _errorText,
                ),
              ),
              actions: <Widget>[
                OutlinedButton(
                  child: Text('common.cancel'.tr()),
                  onPressed: () {
                    setState(() {
                      _errorText = null;
                    });

                    Navigator.of(context).pop();
                  },
                ),
                FilledButton(
                  child: Text('common.confirm'.tr()),
                  onPressed: () async {
                    try {
                      await GetIt.I<LocalDatabase>().updateCategory(
                        CategoryData(
                          id: category.id,
                          categoryName: textController.text,
                        ),
                      );
                    } catch (e) {
                      bool conflictName = e.toString().contains('2067');
                      if (conflictName) {
                        setState(() {
                          _errorText = 'category.duplicate_error'.tr();
                        });
                        return;
                      }
                    }
                    setState(() {
                      _errorText = null;
                    });

                    Navigator.of(context).pop(textController.text);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
