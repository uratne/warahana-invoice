import 'package:flutter/material.dart';
import '../models/catalog_item.dart';
import '../services/catalog_storage_service.dart';

class CatalogAutocomplete extends StatefulWidget {
  final TextEditingController controller;
  final Function(CatalogItem) onItemSelected;

  const CatalogAutocomplete({
    super.key,
    required this.controller,
    required this.onItemSelected,
  });

  @override
  State<CatalogAutocomplete> createState() => _CatalogAutocompleteState();
}

class _CatalogAutocompleteState extends State<CatalogAutocomplete> {
  List<CatalogItem> _allCatalogItems = [];
  List<CatalogItem> _filteredItems = [];
  bool _showSuggestions = false;
  final FocusNode _focusNode = FocusNode();
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();
    _loadCatalog();
    widget.controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  Future<void> _loadCatalog() async {
    final items = await CatalogStorageService.loadCatalog();
    setState(() {
      _allCatalogItems = items;
    });
  }

  void _onTextChanged() {
    final text = widget.controller.text;
    if (text.length >= 3) {
      final filtered = CatalogStorageService.searchCatalog(_allCatalogItems, text);
      setState(() {
        _filteredItems = filtered;
        _showSuggestions = filtered.isNotEmpty;
      });
      _showOverlay();
    } else {
      setState(() {
        _showSuggestions = false;
        _filteredItems = [];
      });
      _removeOverlay();
    }
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      // Delay to allow tap on suggestion to register
      Future.delayed(const Duration(milliseconds: 200), () {
        _removeOverlay();
      });
    }
  }

  void _showOverlay() {
    _removeOverlay();
    if (!_showSuggestions || _filteredItems.isEmpty) return;

    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height),
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(4),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _filteredItems.length,
                itemBuilder: (context, index) {
                  final item = _filteredItems[index];
                  return ListTile(
                    dense: true,
                    title: Text(item.description),
                    subtitle: Text('Rs. ${item.unitPrice.toStringAsFixed(2)}'),
                    onTap: () {
                      widget.onItemSelected(item);
                      _removeOverlay();
                      _focusNode.unfocus();
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _removeOverlay();
    widget.controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        decoration: const InputDecoration(
          hintText: 'Description',
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.all(8),
          suffixIcon: Icon(Icons.search, size: 18),
        ),
      ),
    );
  }
}
