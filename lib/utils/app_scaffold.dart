import 'package:converterpro/helpers/responsive_helper.dart';
import 'package:converterpro/models/conversions.dart';
import 'package:calculator_widget/calculator_widget.dart';
import 'package:converterpro/pages/custom_drawer.dart';
import 'package:converterpro/utils/navigator_utils.dart';
import 'package:converterpro/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:translations/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.child,
    Key? key,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    void openCalculator() {
      showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return CalculatorWidget();
        },
      );
    }

    void clearAll(bool isDrawerFixed) {
      final int page = pageNumberMap[
          GoRouter.of(context).location.substring('/conversions/'.length)]!;
      if (context.read<Conversions>().shouldShowSnackbar(page)) {
        context.read<Conversions>().clearAllValues(page);
        //Snackbar undo request
        final SnackBar snackBar = SnackBar(
          content: Text(AppLocalizations.of(context)!.undoClearAllMessage),
          behavior: SnackBarBehavior.floating,
          width: isDrawerFixed ? 400 : null,
          action: SnackBarAction(
            label: AppLocalizations.of(context)!.undo,
            onPressed: () {
              context.read<Conversions>().undoClearOperation();
            },
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }

    return LayoutBuilder(builder: (context, constraints) {
      // ignore: no_leading_underscores_for_local_identifiers
      final bool _isDrawerFixed = isDrawerFixed(constraints.maxWidth);

      AppPage selectedSection = computeSelectedSection(context);

      Widget drawer = CustomDrawer(
        isDrawerFixed: _isDrawerFixed,
        openCalculator: openCalculator,
      );

      //if the drawer is fixed
      if (_isDrawerFixed) {
        return Scaffold(
          body: SafeArea(
            child: Row(
              children: <Widget>[
                drawer,
                Expanded(child: child),
              ],
            ),
          ),
          floatingActionButton: (selectedSection == AppPage.conversions &&
                  MediaQuery.of(context).viewInsets.bottom == 0)
              ? FloatingActionButton(
                  onPressed: () => clearAll(_isDrawerFixed),
                  tooltip: AppLocalizations.of(context)!.clearAll,
                  child: const Icon(
                    Icons.clear_outlined,
                    color: Colors.white,
                  ),
                )
              : null,
        );
      }
      // if the drawer is not fixed
      return WillPopScope(
        onWillPop: () async {
          switch (selectedSection) {
            case AppPage.settings:
              context.go('/');
              return false;
            case AppPage.reorder:
              context.goNamed('settings');
              return false;
            case AppPage.reorderDetails:
              //2 sided page
              if (_isDrawerFixed) {
                context.goNamed('settings');
              } else {
                context.goNamed('reorder-units');
              }
              return false;
            default:
              return true;
          }
        },
        child: Scaffold(
          drawer: drawer,
          body: SafeArea(child: child),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: selectedSection == AppPage.conversions
              ? BottomAppBar(
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Builder(builder: (context) {
                        return IconButton(
                            tooltip: AppLocalizations.of(context)!.menu,
                            icon: const Icon(Icons.menu),
                            onPressed: () {
                              Scaffold.of(context).openDrawer();
                            });
                      }),
                      IconButton(
                        tooltip: AppLocalizations.of(context)!.clearAll,
                        icon: const Icon(Icons.clear),
                        onPressed: () => clearAll(_isDrawerFixed),
                      ),
                    ],
                  ),
                )
              : null,
          floatingActionButton: (selectedSection == AppPage.conversions &&
                  MediaQuery.of(context).viewInsets.bottom == 0)
              ? FloatingActionButton(
                  tooltip: AppLocalizations.of(context)!.calculator,
                  onPressed: openCalculator,
                  child: const Icon(
                    Icons.calculate_outlined,
                    size: 30,
                    color: Colors.white,
                  ),
                )
              : null,
        ),
      );
    });
  }
}
