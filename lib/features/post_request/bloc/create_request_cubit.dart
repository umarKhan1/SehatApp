import 'package:flutter_bloc/flutter_bloc.dart';

class CreateRequestState {
  const CreateRequestState({
    this.name = '',
    this.bloodGroup,
    this.bags = '',
    this.date,
    this.hospital = '',
    this.reason = '',
    this.contactPerson = '',
    this.mobile = '',
    this.country,
    this.city,
    this.isValid = false,
  });
  final String name;
  final String? bloodGroup;
  final String bags;
  final DateTime? date;
  final String hospital;
  final String reason;
  final String contactPerson;
  final String mobile;
  final String? country;
  final String? city;
  final bool isValid;

  CreateRequestState copyWith({
    String? name,
    String? bloodGroup,
    String? bags,
    DateTime? date,
    String? hospital,
    String? reason,
    String? contactPerson,
    String? mobile,
    String? country,
    String? city,
    bool? isValid,
  }) =>
      CreateRequestState(
        name: name ?? this.name,
        bloodGroup: bloodGroup ?? this.bloodGroup,
        bags: bags ?? this.bags,
        date: date ?? this.date,
        hospital: hospital ?? this.hospital,
        reason: reason ?? this.reason,
        contactPerson: contactPerson ?? this.contactPerson,
        mobile: mobile ?? this.mobile,
        country: country ?? this.country,
        city: city ?? this.city,
        isValid: isValid ?? this.isValid,
      );
}

class CreateRequestCubit extends Cubit<CreateRequestState> {
  CreateRequestCubit() : super(const CreateRequestState());

  void onNameChanged(String v) => _recalc(name: v);
  void setBloodGroup(String? v) => _recalc(bloodGroup: v);
  void onBagsChanged(String v) => _recalc(bags: v);
  void setDate(DateTime? v) => _recalc(date: v);
  void onHospitalChanged(String v) => _recalc(hospital: v);
  void onReasonChanged(String v) => _recalc(reason: v);
  void onContactPersonChanged(String v) => _recalc(contactPerson: v);
  void onMobileChanged(String v) => _recalc(mobile: v);
  void setCountry(String? v) => _recalc(country: v);
  void setCity(String? v) => _recalc(city: v);
  void reset() => emit(const CreateRequestState());

  void _recalc({
    String? name,
    String? bloodGroup,
    String? bags,
    DateTime? date,
    String? hospital,
    String? reason,
    String? contactPerson,
    String? mobile,
    String? country,
    String? city,
  }) {
    final next = state.copyWith(
      name: name,
      bloodGroup: bloodGroup,
      bags: bags,
      date: date,
      hospital: hospital,
      reason: reason,
      contactPerson: contactPerson,
      mobile: mobile,
      country: country,
      city: city,
    );
    final valid = next.name.trim().isNotEmpty &&
        (next.bloodGroup?.isNotEmpty ?? false) &&
        next.bags.trim().isNotEmpty &&
        next.date != null &&
        next.hospital.trim().isNotEmpty &&
        next.reason.trim().isNotEmpty &&
        next.contactPerson.trim().isNotEmpty &&
        next.mobile.trim().isNotEmpty &&
        (next.country?.isNotEmpty ?? false) &&
        (next.city?.isNotEmpty ?? false);
    emit(next.copyWith(isValid: valid));
  }
}
