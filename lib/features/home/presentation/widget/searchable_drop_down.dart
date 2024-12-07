import 'package:flutter/material.dart';

// class SearchableDropdown<T> extends StatefulWidget {
//   const SearchableDropdown(
//       {super.key,
//       required this.items,
//       required this.itemDisplay,
//       required this.selectedItem,
//       required this.onSelected});

//   final List<T> items;
//   final String Function(T) itemDisplay;
//   final T selectedItem;
//   final void Function(T) onSelected;

//   @override
//   State<SearchableDropdown> createState() => _SearchableDropdownState<T>();
// }

// class _SearchableDropdownState<T> extends State<SearchableDropdown> {
//   final TextEditingController _searchController = TextEditingController();
//   late List<T> filteredItems;

//   @override
//   void initState() {
//     filteredItems = List.from(widget.items);
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         TextField(
//           controller: _searchController,
//           decoration: const InputDecoration(
//             labelText: 'Search for Medicines',
//           ),
//           onChanged: (value) {
//             setState(() {
//               filteredItems = (widget.items as List<T>)
//                   .where(
//                     (item) => widget.itemDisplay(item).toLowerCase().contains(
//                           value.toLowerCase(),
//                         ),
//                   )
//                   .toList();
//             });
//           },
//         ),
//         if (filteredItems.isNotEmpty)
//           SizedBox(
//             height: 200,
//             child: SingleChildScrollView(
//               child: Column(
//                 children: List.generate(
//                   widget.items.length,
//                   (index) => ListTile(
//                     onTap: () {},
//                     title: Text(
//                       widget.items[index],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//       ],
//     );
//   }
// }

class SearchableDropDown<T> extends StatefulWidget {
  final TextEditingController searchController;
  final String searchLabel;
  final List<T> items;
  final String Function(T item) itemDisplay;
  final void Function(T item)? onItemSelected;
  final Widget Function(T item)? itemBuilder;
  final Widget Function(TextEditingController searchController)? emptyItmBuilder;
  final String? Function(String? value)? validator;

  const SearchableDropDown(
      {super.key,
      required this.searchController,
      required this.searchLabel,
      required this.items,
      required this.itemDisplay,
      // required this.onSearchChanged,
      this.onItemSelected,
      this.itemBuilder,
      this.emptyItmBuilder,
      this.validator});

  @override
  State<SearchableDropDown<T>> createState() => _SearchableDropDownState<T>();
}

class _SearchableDropDownState<T> extends State<SearchableDropDown<T>> {
  final List<T> searchedItems = [];
  bool isSearching = false;
  // final TextEditingController searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          controller: widget.searchController,
          validator: widget.validator,
          decoration: InputDecoration(
            labelText: widget.searchLabel,
          ),
          onChanged: (value) {
            isSearching = true;
            if (value.isEmpty) {
              isSearching = false;
              searchedItems.clear();
              setState(() {});
              return;
            }
            // onSearchChanged(value);
            final List<T> result = widget.items.where((element) {
              return widget.itemDisplay(element).toLowerCase().contains(value.toLowerCase());
            }).toList();

            if (result.isEmpty) {
              setState(() {
                searchedItems.clear();
              });
              return;
            }

            setState(() {
              searchedItems.addAll(result);
            });
          },
        ),
        if (searchedItems.isNotEmpty)
          SizedBox(
            height: 200,
            child: SingleChildScrollView(
              child: Column(
                children: List.generate(searchedItems.length, (index) {
                  if (widget.itemBuilder != null) {
                    return widget.itemBuilder!(searchedItems[index]);
                  }
                  return ListTile(
                    onTap: () {
                      if (widget.onItemSelected != null) {
                        widget.onItemSelected!(searchedItems[index]);
                      }
                      widget.searchController.text = widget.itemDisplay(searchedItems[index]);
                      isSearching = false;
                      searchedItems.clear();
                      FocusScope.of(context).unfocus();
                      setState(() {});
                    },
                    title: Text(widget.itemDisplay(searchedItems[index])),
                  );
                }),
              ),
            ),
          ),
        if (isSearching && widget.emptyItmBuilder != null && searchedItems.isEmpty)
          widget.emptyItmBuilder!(widget.searchController),
      ],
    );
  }
}
