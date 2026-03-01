import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/models/address_model.dart';
import '../../../core/services/ride_service.dart';
import '../../../core/theme/app_theme.dart';

class AddressSearchField extends StatefulWidget {
  final String hint;
  final AddressModel? value;
  final ValueChanged<AddressModel> onSelected;
  final IconData? prefixIcon;
  final Color? prefixIconColor;
  final List<AddressModel> recentHistory;

  const AddressSearchField({
    super.key,
    required this.hint,
    this.value,
    required this.onSelected,
    this.prefixIcon,
    this.prefixIconColor,
    this.recentHistory = const [],
  });

  @override
  State<AddressSearchField> createState() => _AddressSearchFieldState();
}

class _AddressSearchFieldState extends State<AddressSearchField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _rideService = RideService();

  List<AddressModel> _suggestions = [];
  bool _isLoading = false;
  Timer? _debounce;
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    if (widget.value != null) {
      _controller.text = widget.value!.shortName;
    }
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() {
          _showSuggestions = true;
          if (_controller.text.isEmpty) {
            _suggestions = widget.recentHistory;
          }
        });
      } else {
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) setState(() => _showSuggestions = false);
        });
      }
    });
  }

  @override
  void didUpdateWidget(AddressSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && widget.value != null) {
      if (!_focusNode.hasFocus) {
        _controller.text = widget.value!.shortName;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String query) {
    _debounce?.cancel();

    if (query.trim().length < 2) {
      setState(() {
        _suggestions = widget.recentHistory;
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    _debounce = Timer(const Duration(milliseconds: 400), () async {
      final results = await _rideService.searchAddress(query);
      if (mounted) {
        setState(() {
          _suggestions = results;
          _isLoading = false;
        });
      }
    });
  }

  void _onSelect(AddressModel address) {
    _controller.text = address.shortName;
    _focusNode.unfocus();
    setState(() => _showSuggestions = false);
    widget.onSelected(address);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          onChanged: _onChanged,
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: Icon(
              widget.prefixIcon ?? Icons.search,
              color: widget.prefixIconColor ?? AppTheme.textSecondary,
              size: 20,
            ),
            suffixIcon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.gold,
                      ),
                    ),
                  )
                : _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear,
                            color: AppTheme.textSecondary, size: 18),
                        onPressed: () {
                          _controller.clear();
                          setState(() {
                            _suggestions = widget.recentHistory;
                          });
                        },
                      )
                    : null,
          ),
        ),
        if (_showSuggestions && _suggestions.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 240),
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: AppTheme.surfaceCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 4),
              shrinkWrap: true,
              itemCount: _suggestions.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: Colors.white10),
              itemBuilder: (context, i) {
                final addr = _suggestions[i];
                return ListTile(
                  dense: true,
                  leading: Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: AppTheme.gold.withValues(alpha: 0.8),
                  ),
                  title: Text(
                    addr.shortName,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: addr.city != null || addr.country != null
                      ? Text(
                          [addr.city, addr.country]
                              .where((s) => s != null)
                              .join(', '),
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      : null,
                  onTap: () => _onSelect(addr),
                );
              },
            ),
          ),
      ],
    );
  }
}
