import 'dart:math' as math;
import 'dart:ui' show window;

import 'package:flutter/material.dart';

const double _kDenseButtonHeight = 24.0;
const EdgeInsetsGeometry _kAlignedButtonPadding = EdgeInsetsDirectional.only(start: 16.0, end: 4.0);
const EdgeInsets _kUnalignedButtonPadding = EdgeInsets.zero;

/// A material design button for selecting from a custom widget.
///
/// The type `T` is the type of the [value] that each dropdown item represents.
/// All the entries in a given menu must represent values with consistent types.
/// Typically, an enum is used. Each [DropdownMenuItem] in [items] must be
/// specialized with that same type argument.
///
/// This sample shows a `CustomDropdownButton` with a large arrow icon,
/// purple text style, and bold purple underline, whose value is one of "One",
/// "Two", "Free", or "Four".
///
/// ![](https://flutter.github.io/assets-for-api-docs/assets/material/dropdown_button.png)
///
/// ```dart
/// String dropdownValue = 'One';
///
/// @override
/// Widget build(BuildContext context) {
///   return CustomDropdownButton<String>(
///     value: dropdownValue,
///     icon: Icon(Icons.arrow_downward),
///     iconSize: 24,
///     elevation: 16,
///     style: TextStyle(
///       color: Colors.deepPurple
///     ),
///     underline: Container(
///       height: 2,
///       color: Colors.deepPurpleAccent,
///     ),
///     items: <String>['One', 'Two', 'Free', 'Four']
///       .map<DropdownMenuItem<String>>((String value) {
///         return DropdownMenuItem<String>(
///           value: value,
///           child: Text(value),
///         );
///       })
///       .toList(),
///   );
/// }
/// ```
/// {@end-tool}
///
/// If the [onTap] callback is null or the list of [items] is null
/// then the dropdown button will be disabled, i.e. its arrow will be
/// displayed in grey and it will not respond to input. A disabled button
/// will display the [disabledHint] widget if it is non-null. However, if
/// [disabledHint] is null and [hint] is non-null, the [hint] widget will
/// instead be displayed.
///
/// Requires one of its ancestors to be a [Material] widget.
///
/// See also:
///
///  * [DropdownMenuItem], the class used to represent the [items].
///  * [DropdownButtonHideUnderline], which prevents its descendant dropdown buttons
///    from displaying their underlines.
///  * [ElevatedButton], [TextButton], ordinary buttons that trigger a single action.
///  * <https://material.io/design/components/menus.html#dropdown-menu>
class CustomDropdownButton extends StatefulWidget {
  /// Creates a custom dropdown button.
  ///
  /// The [elevation] and [iconSize] arguments must not be null (they both have
  /// defaults, so do not need to be specified). The boolean [isDense] and
  /// [isExpanded] arguments must not be null.
  ///
  /// The [dropdownColor] argument specifies the background color of the
  /// dropdown when it is open. If it is null, the current theme's
  /// [ThemeData.canvasColor] will be used instead.
  /// TEMP: [DropdownButton] TEMP
  const CustomDropdownButton({
    Key? key,
    this.value,
    this.hint,
    this.disabledHint,
    required this.onTap,
    this.elevation = 8,
    this.style,
    this.underline,
    this.icon,
    this.iconDisabledColor,
    this.iconEnabledColor,
    this.iconSize = 24.0,
    this.isDense = false,
    this.isExpanded = false,
    this.itemHeight = kMinInteractiveDimension,
    this.focusColor,
    this.focusNode,
    this.autofocus = false,
    this.dropdownColor,
  })  : assert(itemHeight >= kMinInteractiveDimension),
        super(key: key);

  /// The value of the button text.
  ///
  /// If [value] is null and [hint] is non-null, the [hint] widget is
  /// displayed as a placeholder for the dropdown button's value.
  final String? value;

  /// A placeholder String that is displayed by the dropdown button.
  ///
  /// If [value] is null, this String is displayed as a placeholder for
  /// the dropdown button's value. This String is also displayed if the button
  /// is disabled ([onTap] is null) and [disabledHint] is null.
  final String? hint;

  /// A message to show when the dropdown is disabled.
  ///
  /// Displayed if [onTap] is null. If [hint] is non-null and
  /// [disabledHint] is null, the [hint] widget will be displayed instead.
  final String? disabledHint;

  /// Called when the dropdown button is tapped.
  ///
  /// The callback will not be invoked if the dropdown button is disabled.
  final VoidCallback onTap;

  /// When a [DropdownMenuItem] is selected, the widget that will be displayed
  /// from the list corresponds to the [DropdownMenuItem] of the same index
  /// in [items].
  ///
  /// {@tool dartpad --template=stateful_widget_scaffold}
  ///
  /// This sample shows a `CustomDropdownButton` with a button with [Text] that
  /// corresponds to but is unique from [DropdownMenuItem].
  ///
  /// ```dart
  /// final List<String> items = <String>['1','2','3'];
  /// String selectedItem = '1';
  ///
  /// @override
  /// Widget build(BuildContext context) {
  ///   return Padding(
  ///     padding: const EdgeInsets.symmetric(horizontal: 12.0),
  ///     child: CustomDropdownButton<String>(
  ///       value: selectedItem,
  ///       items: items.map((String item) {
  ///         return DropdownMenuItem<String>(
  ///           child: Text('Log $item'),
  ///           value: item,
  ///         );
  ///       }).toList(),
  ///     ),
  ///   );
  /// }
  /// ```
  /// {@end-tool}
  ///
  /// The z-coordinate at which to place the menu when open.
  ///
  /// The following elevations have defined shadows: 1, 2, 3, 4, 6, 8, 9, 12,
  /// 16, and 24. See [kElevationToShadow].
  ///
  /// Defaults to 8, the appropriate elevation for dropdown buttons.
  final int elevation;

  /// The text style to use for text in the dropdown button and the dropdown
  /// menu that appears when you tap the button.
  ///
  /// This sample shows a `DropdownButton` with a dropdown button text style
  /// that is different than its menu items.
  ///
  /// ```dart
  /// List<String> options = <String>['One', 'Two', 'Free', 'Four'];
  /// String dropdownValue = 'One';
  ///
  /// @override
  /// Widget build(BuildContext context) {
  ///   return Container(
  ///     alignment: Alignment.center,
  ///     color: Colors.blue,
  ///     child: DropdownButton<String>(
  ///       value: dropdownValue,
  ///       style: TextStyle(color: Colors.blue),
  ///     ),
  ///   );
  /// }
  /// ```
  /// {@end-tool}
  ///
  /// Defaults to the [TextTheme.subtitle1] value of the current
  /// [ThemeData.textTheme] of the current [Theme].
  final TextStyle? style;

  /// The widget to use for drawing the drop-down button's underline.
  ///
  /// Defaults to a 0.0 width bottom border with color 0xFFBDBDBD.
  final Widget? underline;

  /// The widget to use for the drop-down button's icon.
  ///
  /// Defaults to an [Icon] with the [Icons.arrow_drop_down] glyph.
  final Widget? icon;

  /// The color of any [Icon] descendant of [icon] if this button is disabled,
  /// i.e. if [onTap] is null.
  ///
  /// Defaults to [Colors.grey.shade400] when the theme's
  /// [ThemeData.brightness] is [Brightness.light] and to
  /// [Colors.white10] when it is [Brightness.dark]
  final Color? iconDisabledColor;

  /// The color of any [Icon] descendant of [icon] if this button is enabled,
  /// i.e. if [onTap] is defined.
  ///
  /// Defaults to [Colors.grey.shade700] when the theme's
  /// [ThemeData.brightness] is [Brightness.light] and to
  /// [Colors.white70] when it is [Brightness.dark]
  final Color? iconEnabledColor;

  /// The size to use for the drop-down button's down arrow icon button.
  ///
  /// Defaults to 24.0.
  final double iconSize;

  /// Reduce the button's height.
  ///
  /// By default this button's height is the same as its menu items' heights.
  /// If isDense is true, the button's height is reduced by about half. This
  /// can be useful when the button is embedded in a container that adds
  /// its own decorations, like [InputDecorator].
  final bool isDense;

  /// Set the dropdown's inner contents to horizontally fill its parent.
  ///
  /// By default this button's inner width is the minimum size of its contents.
  /// If [isExpanded] is true, the inner width is expanded to fill its
  /// surrounding container.
  final bool isExpanded;

  /// If null, then the menu item heights will vary according to each menu item's
  /// intrinsic height.
  ///
  /// The default value is [kMinInteractiveDimension], which is also the minimum
  /// height for menu items.
  ///
  /// If this value is null and there isn't enough vertical room for the menu,
  /// then the menu's initial scroll offset may not align the selected item with
  /// the dropdown button. That's because, in this case, the initial scroll
  /// offset is computed as if all of the menu item heights were
  /// [kMinInteractiveDimension].
  final double itemHeight;

  /// The color for the button's [Material] when it has the input focus.
  final Color? focusColor;

  /// {@macro flutter.widgets.Focus.focusNode}
  final FocusNode? focusNode;

  /// {@macro flutter.widgets.Focus.autofocus}
  final bool autofocus;

  /// The background color of the dropdown.
  ///
  /// If it is not provided, the theme's [ThemeData.canvasColor] will be used
  /// instead.
  final Color? dropdownColor;

  @override
  _CustomDropdownButtonState createState() => _CustomDropdownButtonState();
}

class _CustomDropdownButtonState<T> extends State<CustomDropdownButton> with WidgetsBindingObserver {
  Orientation? _lastOrientation;
  FocusNode? _internalNode;
  FocusNode? get focusNode => widget.focusNode ?? _internalNode;
  bool _hasPrimaryFocus = false;
  late Map<Type, Action<Intent>> _actionMap;
  FocusHighlightMode? _focusHighlightMode;

  // Only used if needed to create _internalNode.
  FocusNode _createFocusNode() {
    return FocusNode(debugLabel: '${widget.runtimeType}');
  }

  @override
  void initState() {
    super.initState();
    _updateSelectedIndex();
    if (widget.focusNode == null) {
      _internalNode ??= _createFocusNode();
    }
    _actionMap = <Type, Action<Intent>>{
      ActivateAction: CallbackAction(
        onInvoke: (Intent intent) {
          _handleTap();
          return null;
        },
      ),
    };
    focusNode!.addListener(_handleFocusChanged);
    final FocusManager focusManager = WidgetsBinding.instance.focusManager;
    _focusHighlightMode = focusManager.highlightMode;
    focusManager.addHighlightModeListener(_handleFocusHighlightModeChange);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _removeDropdownRoute();
    WidgetsBinding.instance.focusManager.removeHighlightModeListener(_handleFocusHighlightModeChange);
    focusNode!.removeListener(_handleFocusChanged);
    _internalNode?.dispose();
    super.dispose();
  }

  void _removeDropdownRoute() {
    _lastOrientation = null;
  }

  void _handleFocusChanged() {
    if (_hasPrimaryFocus != focusNode!.hasPrimaryFocus) {
      setState(() {
        _hasPrimaryFocus = focusNode!.hasPrimaryFocus;
      });
    }
  }

  void _handleFocusHighlightModeChange(FocusHighlightMode mode) {
    if (!mounted) {
      return;
    }
    setState(() {
      _focusHighlightMode = mode;
    });
  }

  @override
  void didUpdateWidget(CustomDropdownButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      oldWidget.focusNode?.removeListener(_handleFocusChanged);
      if (widget.focusNode == null) {
        _internalNode ??= _createFocusNode();
      }
      _hasPrimaryFocus = focusNode!.hasPrimaryFocus;
      focusNode!.addListener(_handleFocusChanged);
    }
    _updateSelectedIndex();
  }

  void _updateSelectedIndex() {
    if (!_enabled) {
      return;
    }
  }

  TextStyle? get _textStyle => widget.style ?? Theme.of(context).textTheme.subtitle1;

  void _handleTap() {
    widget.onTap();
  }

  // When isDense is true, reduce the height of this button from _kMenuItemHeight to
  // _kDenseButtonHeight, but don't make it smaller than the text that it contains.
  // Similarly, we don't reduce the height of the button so much that its icon
  // would be clipped.
  double get _denseButtonHeight {
    final double fontSize = _textStyle!.fontSize ?? Theme.of(context).textTheme.subtitle1!.fontSize!;
    return math.max(fontSize, math.max(widget.iconSize, _kDenseButtonHeight));
  }

  Color? get _iconColor {
    // These colors are not defined in the Material Design spec.
    if (_enabled) {
      if (widget.iconEnabledColor != null) return widget.iconEnabledColor;

      switch (Theme.of(context).brightness) {
        case Brightness.light:
          return Colors.grey.shade700;
        case Brightness.dark:
          return Colors.white70;
      }
    } else {
      if (widget.iconDisabledColor != null) return widget.iconDisabledColor;

      switch (Theme.of(context).brightness) {
        case Brightness.light:
          return Colors.grey.shade400;
        case Brightness.dark:
          return Colors.white10;
      }
    }
  }

  bool get _enabled => true;

  Orientation _getOrientation(BuildContext context) {
    Orientation result;
    try {
      result = MediaQuery.of(context).orientation;
      return result;
    } on Exception {
      // If there's no MediaQuery, then use the window aspect to determine
      // orientation.
      final Size size = window.physicalSize;
      result = size.width > size.height ? Orientation.landscape : Orientation.portrait;
    }
    return result;
  }

  bool? get _showHighlight {
    switch (_focusHighlightMode) {
      case FocusHighlightMode.touch:
        return false;
      case FocusHighlightMode.traditional:
        return _hasPrimaryFocus;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));
    assert(debugCheckHasMaterialLocalizations(context));
    final Orientation newOrientation = _getOrientation(context);
    _lastOrientation ??= newOrientation;
    if (newOrientation != _lastOrientation) {
      _removeDropdownRoute();
      _lastOrientation = newOrientation;
    }

    Widget innerItemsWidget;

    if (widget.value != null) {
      innerItemsWidget = Text(widget.value!);
    } else if (widget.hint != null || (!_enabled && widget.disabledHint != null)) {
      Widget displayedHint = _enabled ? Text(widget.hint!) : Text(widget.disabledHint!);

      innerItemsWidget = DefaultTextStyle(
        style: _textStyle!.copyWith(color: Theme.of(context).hintColor),
        child: IgnorePointer(
          ignoringSemantics: false,
          child: displayedHint,
        ),
      );
    } else {
      innerItemsWidget = Container();
    }

    innerItemsWidget = SizedBox(height: widget.itemHeight, child: Align(child: innerItemsWidget));

    final EdgeInsetsGeometry padding =
        ButtonTheme.of(context).alignedDropdown ? _kAlignedButtonPadding : _kUnalignedButtonPadding;

    const Icon defaultIcon = Icon(Icons.arrow_drop_down);

    Widget result = DefaultTextStyle(
      style: _textStyle!,
      child: Container(
        decoration: _showHighlight!
            ? BoxDecoration(
                color: widget.focusColor ?? Theme.of(context).focusColor,
                borderRadius: const BorderRadius.all(Radius.circular(4.0)),
              )
            : null,
        padding: padding.resolve(Directionality.of(context)),
        height: widget.isDense ? _denseButtonHeight : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (widget.isExpanded) Expanded(child: innerItemsWidget) else innerItemsWidget,
            IconTheme(
              data: IconThemeData(
                color: _iconColor,
                size: widget.iconSize,
              ),
              child: widget.icon ?? defaultIcon,
            ),
          ],
        ),
      ),
    );

    if (!DropdownButtonHideUnderline.at(context)) {
      final double bottom = (widget.isDense) ? 0.0 : 8.0;
      result = Stack(
        children: <Widget>[
          result,
          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: bottom,
            child: widget.underline ??
                Container(
                  height: 1.0,
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0xFFBDBDBD),
                        width: 0.0,
                      ),
                    ),
                  ),
                ),
          ),
        ],
      );
    }

    return Semantics(
      button: true,
      child: Actions(
        actions: _actionMap,
        child: Focus(
          canRequestFocus: _enabled,
          focusNode: focusNode,
          autofocus: widget.autofocus,
          child: GestureDetector(
            onTap: _enabled ? _handleTap : null,
            behavior: HitTestBehavior.opaque,
            child: result,
          ),
        ),
      ),
    );
  }
}
