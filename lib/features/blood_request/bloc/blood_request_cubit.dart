import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sehatapp/features/blood_request/data/blood_request_repository.dart';

class BloodRequestState {
  const BloodRequestState({this.loading = false, this.items = const [], this.error});
  final bool loading;
  final List<Map<String, dynamic>> items;
  final String? error;
  BloodRequestState copyWith({bool? loading, List<Map<String, dynamic>>? items, String? error}) =>
      BloodRequestState(loading: loading ?? this.loading, items: items ?? this.items, error: error);
}

class BloodRequestCubit extends Cubit<BloodRequestState> {
  BloodRequestCubit(this.repo) : super(const BloodRequestState());
  final BloodRequestRepository repo;

  Stream<List<Map<String, dynamic>>>? _sub;

  void start({String? bloodGroup, String? excludeUid}) {
    emit(state.copyWith(loading: true, ));
    _sub = repo.streamRequests(bloodGroup: bloodGroup, excludeUid: excludeUid);
    _sub!.listen((items) {
      emit(state.copyWith(loading: false, items: items));
    }, onError: (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    });
  }

  @override
  Future<void> close() {
    // No manual cancel needed for stream; but reset state
    emit(const BloodRequestState());
    return super.close();
  }
}
