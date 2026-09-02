import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/addresses_api.dart';
import '../data/models/address.dart';

final addressesApiProvider = Provider<AddressesApi>((ref) {
  return AddressesApi(ref.watch(apiClientProvider));
});

class AddressesState {
  final List<Address> items;
  final bool isLoading;
  final String? error;

  const AddressesState({this.items = const [], this.isLoading = false, this.error});

  AddressesState copyWith({List<Address>? items, bool? isLoading, String? error, bool clearError = false}) {
    return AddressesState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AddressesController extends StateNotifier<AddressesState> {
  final AddressesApi _api;

  AddressesController(this._api) : super(const AddressesState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final items = await _api.list();
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> create({
    required int governorateId,
    required int cityId,
    required String addressLine,
    String? zipCode,
    bool isPrimary = false,
  }) async {
    await _api.create(
      governorateId: governorateId,
      cityId: cityId,
      addressLine: addressLine,
      zipCode: zipCode,
      isPrimary: isPrimary,
    );
    await load();
  }

  Future<void> update(
    int id, {
    required int governorateId,
    required int cityId,
    required String addressLine,
    String? zipCode,
  }) async {
    await _api.update(
      id,
      governorateId: governorateId,
      cityId: cityId,
      addressLine: addressLine,
      zipCode: zipCode,
    );
    await load();
  }

  Future<void> setPrimary(int id) async {
    await _api.setPrimary(id);
    await load();
  }

  Future<void> delete(int id) async {
    await _api.delete(id);
    await load();
  }
}

final addressesControllerProvider = StateNotifierProvider<AddressesController, AddressesState>((ref) {
  return AddressesController(ref.watch(addressesApiProvider));
});
