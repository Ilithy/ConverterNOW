import 'package:calculator_widget/animated_button.dart';
import 'package:calculator_widget/calculator_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:translations/app_localizations.dart';

class CalculatorWidget extends StatelessWidget {
  // Style
  late double buttonHeight;

  final FocusNode focusKeyboard = FocusNode();
  static const String decimalSeparator = '.';

  final double modalHeight;
  static const double handleHeight = 8;

  CalculatorWidget({
    required this.modalHeight,
    Key? key,
  }) : super(key: key) {
    buttonHeight = (modalHeight - handleHeight) / 6;
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Color buttonOpColor = Color.alphaBlend(
      (brightness == Brightness.light ? Colors.white : Colors.black)
          .withOpacity(0.6),
      Theme.of(context).primaryColor,
    );
    final Color buttonNumberColor = Color.alphaBlend(
      (brightness == Brightness.light ? Colors.white : Colors.black)
          .withOpacity(0.9),
      Theme.of(context).primaryColor,
    );
    final Color buttonDelColor = Color.alphaBlend(
      (brightness == Brightness.light ? Colors.white : Colors.black)
          .withOpacity(0.6),
      Theme.of(context).colorScheme.secondary,
    );

    return ChangeNotifierProvider(
      create: (_) => Calculator(),
      child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        final double calcWidth = _getCalcWidth(constraints.maxWidth);
        final int columnsNumber = _getColumnsNumber(calcWidth);
        final double buttonWidth = _getButtonWidth(calcWidth, columnsNumber);

        // Request focus on this widget, otherwise we are not able to use the
        // HW keyboard immediately when the calculator pops up.
        focusKeyboard.requestFocus();

        String text =
            context.select<Calculator, String>((calc) => calc.currentNumber);

        return SizedBox(
          height: modalHeight,
          child: KeyboardListener(
            focusNode: focusKeyboard,
            onKeyEvent: (KeyEvent event) {
              if (event.runtimeType.toString() == 'KeyDownEvent') {
                if (event.logicalKey == LogicalKeyboardKey.backspace) {
                  context.read<Calculator>().adaptiveDeleteClear();
                } else if (event.logicalKey == LogicalKeyboardKey.delete) {
                  context.read<Calculator>().clearAll();
                } else if (event.logicalKey == LogicalKeyboardKey.enter) {
                  context.read<Calculator>().submitChar('=');
                } else {
                  context.read<Calculator>().submitChar(event.character ?? '');
                }
              }
            },
            child: Column(
              children: <Widget>[
                Container(
                  height: buttonHeight + handleHeight,
                  alignment: const Alignment(0, 0),
                  decoration: BoxDecoration(
                    color: buttonNumberColor,
                    borderRadius: BorderRadius.circular(buttonHeight / 2),
                  ),
                  child: Column(
                    children: [
                      // Handle
                      Center(
                        child: Padding(
                          padding:
                              const EdgeInsets.only(top: (handleHeight - 3)),
                          child: Container(
                            width: 50,
                            height: 3,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(1.5),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: SelectableText(
                              text,
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                              ),
                              textAlign: TextAlign.end,
                              maxLines: 1,
                              scrollPhysics: const ClampingScrollPhysics(),
                              toolbarOptions: const ToolbarOptions(
                                  copy: true, selectAll: true),
                            ),
                          ),
                          Container(
                            height: buttonHeight,
                            width: buttonWidth,
                            alignment: Alignment.center,
                            child: context.select<Calculator, bool>(
                                    (calc) => calc.isResult)
                                ? IconButton(
                                    tooltip: AppLocalizations.of(context)?.copy,
                                    icon: Icon(
                                      Icons.content_copy,
                                      color: brightness == Brightness.dark
                                          ? Colors.white54
                                          : Colors.black54,
                                    ),
                                    onPressed: () {
                                      Clipboard.setData(
                                          ClipboardData(text: text));
                                    },
                                  )
                                : Text(
                                    context.select<Calculator, String>(
                                        (calc) => calc.stringOperation),
                                    style: TextStyle(
                                      fontSize: 45.0,
                                      fontWeight: FontWeight.bold,
                                      color: brightness == Brightness.dark
                                          ? Colors.white54
                                          : Colors.black54,
                                    ),
                                    maxLines: 1,
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                //start of butttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    if (columnsNumber > 5)
                      Column(
                        children: <Widget>[
                          CalculatorButton(
                              text: 'x²',
                              buttonSize: buttonHeight,
                              backgroundColor: buttonOpColor,
                              onPressed: () {
                                context.read<Calculator>().square();
                              }),
                          CalculatorButton(
                              text: 'ln',
                              buttonSize: buttonHeight,
                              backgroundColor: buttonOpColor,
                              onPressed: () {
                                context.read<Calculator>().ln();
                              }),
                          CalculatorButton(
                              text: 'n!',
                              buttonSize: buttonHeight,
                              backgroundColor: buttonOpColor,
                              onPressed: () {
                                context.read<Calculator>().factorial();
                              }),
                          CalculatorButton(
                              text: '1/x',
                              buttonSize: buttonHeight,
                              backgroundColor: buttonOpColor,
                              onPressed: () {
                                context.read<Calculator>().reciprocal();
                              }),
                        ],
                      ),
                    if (columnsNumber > 4)
                      Column(
                        children: <Widget>[
                          CalculatorButton(
                              text: '√',
                              buttonSize: buttonHeight,
                              backgroundColor: buttonOpColor,
                              onPressed: () {
                                context.read<Calculator>().squareRoot();
                              }),
                          CalculatorButton(
                              text: 'log',
                              buttonSize: buttonHeight,
                              backgroundColor: buttonOpColor,
                              onPressed: () {
                                context.read<Calculator>().log10();
                              }),
                          CalculatorButton(
                              text: 'e',
                              buttonSize: buttonHeight,
                              backgroundColor: buttonOpColor,
                              onPressed: () {
                                context.read<Calculator>().submitChar('e');
                              }),
                          CalculatorButton(
                              text: 'π',
                              buttonSize: buttonHeight,
                              backgroundColor: buttonOpColor,
                              onPressed: () {
                                context.read<Calculator>().submitChar('π');
                              }),
                        ],
                      ),
                    Column(children: [
                      Row(
                        children: [
                          CalculatorButton(
                            text: '√',
                            buttonSize: buttonHeight,
                            backgroundColor: buttonOpColor,
                            onPressed: () {
                              context.read<Calculator>().squareRoot();
                            },
                          ),
                          CalculatorButton(
                            text: 'x²',
                            buttonSize: buttonHeight,
                            backgroundColor: buttonOpColor,
                            onPressed: () {
                              context.read<Calculator>().square();
                            },
                          ),
                          CalculatorButton(
                            text: 'π',
                            buttonSize: buttonHeight,
                            backgroundColor: buttonOpColor,
                            onPressed: () {
                              context.read<Calculator>().submitChar('π');
                            },
                          ),
                        ],
                      ),
                      Column(
                        //creates numbers buttons from 1 to 9
                        children: List<Widget>.generate(3, (i) {
                          return Row(
                            children: List.generate(3, (j) {
                              // (2-i)*3 + j+1 = 7-3*i+j
                              String char = (7 - 3 * i + j).toString();
                              return CalculatorButton(
                                  text: char,
                                  buttonSize: buttonHeight,
                                  backgroundColor: buttonNumberColor,
                                  onPressed: () {
                                    context.read<Calculator>().submitChar(char);
                                  });
                            }),
                          );
                        }),
                      ),
                      Row(children: <Widget>[
                        CalculatorButton(
                            text: decimalSeparator,
                            buttonSize: buttonHeight,
                            backgroundColor: buttonOpColor,
                            onPressed: () {
                              context
                                  .read<Calculator>()
                                  .submitChar(decimalSeparator);
                            }),
                        CalculatorButton(
                            text: '0',
                            buttonSize: buttonHeight,
                            backgroundColor: buttonNumberColor,
                            onPressed: () {
                              context.read<Calculator>().submitChar('0');
                            }),
                        CalculatorButton(
                            text: '=',
                            buttonSize: buttonHeight,
                            backgroundColor: buttonOpColor,
                            bottomPadding: 5,
                            onPressed: () {
                              context.read<Calculator>().submitChar('=');
                            }),
                      ]),
                    ]),
                    Column(
                      children: <Widget>[
                        CalculatorButton(
                            text: context.select<Calculator, bool>(
                                    (calc) => calc.endNumber)
                                ? 'CE'
                                : '←',
                            buttonSize: buttonHeight,
                            backgroundColor: buttonDelColor,
                            onPressed: () {
                              context.read<Calculator>().adaptiveDeleteClear();
                            },
                            onLongPress: () {
                              context.read<Calculator>().clearAll();
                            }),
                        CalculatorButton(
                            text: '÷',
                            buttonSize: buttonHeight,
                            backgroundColor: buttonOpColor,
                            bottomPadding: 5,
                            onPressed: () {
                              context.read<Calculator>().submitChar('/');
                            }),
                        CalculatorButton(
                            text: '×',
                            buttonSize: buttonHeight,
                            backgroundColor: buttonOpColor,
                            bottomPadding: 5,
                            onPressed: () {
                              context.read<Calculator>().submitChar('*');
                            }),
                        CalculatorButton(
                            text: '−',
                            buttonSize: buttonHeight,
                            backgroundColor: buttonOpColor,
                            bottomPadding: 5,
                            onPressed: () {
                              context.read<Calculator>().submitChar('-');
                            }),
                        CalculatorButton(
                            text: '+',
                            buttonSize: buttonHeight,
                            backgroundColor: buttonOpColor,
                            bottomPadding: 5,
                            onPressed: () {
                              context.read<Calculator>().submitChar('+');
                            }),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

///Returns the width of one button given all the available width
double _getButtonWidth(double calcWidth, int columnNumber) {
  return (calcWidth * 0.9) / columnNumber;
}

///Returns the width of the calculator
double _getCalcWidth(double totalWidth) {
  const double maxCalcWidth = 800;
  return totalWidth < maxCalcWidth ? totalWidth : maxCalcWidth;
}

int _getColumnsNumber(double calcWidth) {
  if (calcWidth < 400) {
    return 4;
  } else if (calcWidth < 500) {
    return 5;
  }
  return 6;
}

class CalculatorButton extends StatelessWidget {
  final String? text;
  final double buttonSize;
  final double bottomPadding;
  final void Function()? onPressed;
  final void Function()? onLongPress;
  final Color backgroundColor;

  const CalculatorButton({
    Key? key,
    this.text,
    required this.buttonSize,
    required this.backgroundColor,
    this.onLongPress,
    this.onPressed,
    this.bottomPadding = 0,
  }) : super(key: key);

  static const double padding = 3;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    return Padding(
      padding: const EdgeInsets.all(padding),
      child: AnimatedButton(
        onPressed: onPressed,
        onLongPress: onLongPress,
        initialRadius: buttonSize / 2,
        finalRadius: buttonSize / 5,
        foregroundColor: Colors.white,
        backgroundColor: backgroundColor,
        child: SizedBox(
          width: (buttonSize - 2 * padding) * 0.55,
          height: buttonSize - 2 * padding,
          child: Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: bottomPadding),
              child: text == "←"
                  ? const Icon(
                      Icons.backspace_outlined,
                      color: Colors.black,
                    )
                  : Text(
                      text ?? '',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
