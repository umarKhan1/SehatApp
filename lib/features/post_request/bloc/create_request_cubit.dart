import 'package:flutter_bloc/flutter_bloc.dart';

class CreateRequestState {
  const CreateRequestState({this.bloodGroup, this.country, this.city, this.date});
  final String? bloodGroup;
  final String? country;
  final String? city;
  final DateTime? date;
  CreateRequestState copyWith({String? bloodGroup, String? country, String? city, DateTime? date}) =>
      CreateRequestState(
        bloodGroup: bloodGroup ?? this.bloodGroup,
        country: country ?? this.country,
        city: city ?? this.city,
        date: date ?? this.date,
      );
}

class CreateRequestCubit extends Cubit<CreateRequestState> {
  CreateRequestCubit() : super(const CreateRequestState());
  void setBloodGroup(String? v) => emit(state.copyWith(bloodGroup: v));
  void setCountry(String? v) => emit(state.copyWith(country: v, ));
  void setCity(String? v) => emit(state.copyWith(city: v));
  void setDate(DateTime? v) => emit(state.copyWith(date: v));
}
