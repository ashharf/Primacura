// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:flutter/scheduler.dart';

// class Autocomplete2<T extends Object> extends StatelessWidget {
//   /// Creates an instance of [Autocomplete2].
//   const Autocomplete2({
//     super.key,
//     required this.optionsBuilder,
//     this.displayStringForOption = RawAutocomplete.defaultStringForOption,
//     this.fieldViewBuilder = _defaultFieldViewBuilder,
//     this.onSelected,
//     this.optionsMaxHeight = 200.0,
//     required this.optionsViewBuilder,
//     this.optionsViewOpenDirection = OptionsViewOpenDirection.down,
//     this.initialValue,
//   });
//   final String Function(T option) displayStringForOption;
//   final Widget Function(BuildContext context, TextEditingController textEditingController, FocusNode focusNode,
//       VoidCallback onFieldSubmitted) fieldViewBuilder;
//   final void Function(T option)? onSelected;
//   final FutureOr<Iterable<T>> Function(TextEditingValue) optionsBuilder;
//   final Widget Function(
//     BuildContext context,
//     void Function(T option) onSelected,
//     Iterable<T> options,
//   ) optionsViewBuilder;
//   final OptionsViewOpenDirection optionsViewOpenDirection;
//   final double optionsMaxHeight;
//   final TextEditingValue? initialValue;

//   static Widget _defaultFieldViewBuilder(BuildContext context, TextEditingController textEditingController,
//       FocusNode focusNode, VoidCallback onFieldSubmitted) {
//     return _AutocompleteField(
//       focusNode: focusNode,
//       textEditingController: textEditingController,
//       onFieldSubmitted: onFieldSubmitted,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return RawAutocomplete<T>(
//       displayStringForOption: displayStringForOption,
//       fieldViewBuilder: fieldViewBuilder,
//       initialValue: initialValue,
//       optionsBuilder: optionsBuilder,
//       optionsViewOpenDirection: optionsViewOpenDirection,
//       optionsViewBuilder: optionsViewBuilder,
//       // ??
//       //     (BuildContext context, AutocompleteOnSelected<T> onSelected, Iterable<T> options) {
//       //       return _AutocompleteOptions<T>(
//       //         displayStringForOption: displayStringForOption,
//       //         onSelected: onSelected,
//       //         options: options,
//       //         openDirection: optionsViewOpenDirection,
//       //         maxOptionsHeight: optionsMaxHeight,
//       //       );
//       //     },
//       onSelected: onSelected,
//     );
//   }
// }

// // The default Material-style Autocomplete text field.
// class _AutocompleteField extends StatelessWidget {
//   const _AutocompleteField({
//     required this.focusNode,
//     required this.textEditingController,
//     required this.onFieldSubmitted,
//   });

//   final FocusNode focusNode;

//   final VoidCallback onFieldSubmitted;

//   final TextEditingController textEditingController;

//   @override
//   Widget build(BuildContext context) {
//     return TextFormField(
//       controller: textEditingController,
//       focusNode: focusNode,
//       onFieldSubmitted: (String value) {
//         onFieldSubmitted();
//       },
//     );
//   }
// }

// // The default Material-style Autocomplete options.
// class _AutocompleteOptions<T extends Object> extends StatelessWidget {
//   const _AutocompleteOptions({
//     super.key,
//     required this.displayStringForOption,
//     required this.onSelected,
//     required this.openDirection,
//     required this.options,
//     required this.maxOptionsHeight,
//   });

//   final AutocompleteOptionToString<T> displayStringForOption;

//   final AutocompleteOnSelected<T> onSelected;
//   final OptionsViewOpenDirection openDirection;

//   final Iterable<T> options;
//   final double maxOptionsHeight;

//   @override
//   Widget build(BuildContext context) {
//     final AlignmentDirectional optionsAlignment = switch (openDirection) {
//       OptionsViewOpenDirection.up => AlignmentDirectional.bottomStart,
//       OptionsViewOpenDirection.down => AlignmentDirectional.topStart,
//     };
//     return Align(
//       alignment: optionsAlignment,
//       child: Material(
//         elevation: 4.0,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(maxHeight: maxOptionsHeight),
//           child: Column(
//             children: [
//               ListView.builder(
//                 padding: EdgeInsets.zero,
//                 shrinkWrap: true,
//                 itemCount: options.length,
//                 itemBuilder: (BuildContext context, int index) {
//                   final T option = options.elementAt(index);
//                   return InkWell(
//                     onTap: () {
//                       onSelected(option);
//                     },
//                     child: Builder(builder: (BuildContext context) {
//                       final bool highlight = AutocompleteHighlightedOption.of(context) == index;
//                       if (highlight) {
//                         SchedulerBinding.instance.addPostFrameCallback((Duration timeStamp) {
//                           Scrollable.ensureVisible(context, alignment: 0.5);
//                         }, debugLabel: 'AutocompleteOptions.ensureVisible');
//                       }
//                       return Container(
//                         color: highlight ? Theme.of(context).focusColor : null,
//                         padding: const EdgeInsets.all(16.0),
//                         child: Text(displayStringForOption(option)),
//                       );
//                     }),
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
