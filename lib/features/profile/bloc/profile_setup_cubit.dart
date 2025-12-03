import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileSetupState {
  const ProfileSetupState({
    this.name = '',
    this.phone = '',
    this.bloodGroup = '',
    this.country = '',
    this.city = '',
    this.photoUrl,
    // Step 2 fields
    this.dob,
    this.gender = '',
    this.wantToDonate,
    this.about = '',
    this.age,
    this.isValid = false,
    this.submitting = false,
    this.error,
    this.step = 1,
  });

  final String name;
  final String phone;
  final String bloodGroup;
  final String country;
  final String city;
  final String? photoUrl;
  // Step 2
  final DateTime? dob;
  final String gender; // 'Male', 'Female', 'Other'
  final bool? wantToDonate; // null until selected
  final String about;
  final int? age; // derived from dob
  final bool isValid;
  final bool submitting;
  final String? error;
  final int step; // can be 1 or 2

  ProfileSetupState copyWith({
    String? name,
    String? phone,
    String? bloodGroup,
    String? country,
    String? city,
    String? photoUrl,
    // step 2
    DateTime? dob,
    String? gender,
    bool? wantToDonate,
    String? about,
    int? age,
    bool? isValid,
    bool? submitting,
    String? error,
    int? step,
  }) {
    return ProfileSetupState(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      country: country ?? this.country,
      city: city ?? this.city,
      photoUrl: photoUrl ?? this.photoUrl,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      wantToDonate: wantToDonate ?? this.wantToDonate,
      about: about ?? this.about,
      age: age ?? this.age,
      isValid: isValid ?? this.isValid,
      submitting: submitting ?? this.submitting,
      error: error,
      step: step ?? this.step,
    );
  }
}

class ProfileSetupCubit extends Cubit<ProfileSetupState> {
  ProfileSetupCubit() : super(const ProfileSetupState());

  void onNameChanged(String v) => _recalc(name: v);
  void onPhoneChanged(String v) => _recalc(phone: v);
  void onBloodGroupChanged(String v) => _recalc(bloodGroup: v);
  void onCountryChanged(String v) => _recalc(country: v);
  void onCityChanged(String v) => _recalc(city: v);
  void setPhotoUrl(String? url) => emit(state.copyWith(photoUrl: url));

  // Step 2 handlers
  void setDob(DateTime v) {
    final nextAge = _calculateAge(v);
    _recalc(dob: v, age: nextAge);
  }
  void onGenderChanged(String v) => _recalc(gender: v);
  void onWantToDonateChanged(bool v) => _recalc(wantToDonate: v);
  void onAboutChanged(String v) => _recalc(about: v);

  void nextStep() {
    if (state.step == 1 && _validateStep1(state)) {
      emit(state.copyWith(step: 2, isValid: _validateStep2(state)));
    }
  }

  void prevStep() {
    if (state.step > 1) {
      // When returning to step 1, recompute validity using step 1 rules
      final s1Valid = _validateStep1(state);
      emit(state.copyWith(step: state.step - 1, isValid: s1Valid));
    } else {
      emit(state.copyWith(step: 1, isValid: _validateStep1(state)));
    }
  }

  bool _validateStep1(ProfileSetupState s) {
    final nameOk = s.name.trim().isNotEmpty;
    final phoneOk = s.phone.trim().length >= 8;
    final bloodOk = s.bloodGroup.trim().isNotEmpty;
    final countryOk = s.country.trim().isNotEmpty;
    final cityOk = s.city.trim().isNotEmpty;
    return nameOk && phoneOk && bloodOk && countryOk && cityOk;
  }

  bool _validateStep2(ProfileSetupState s) {
    final dobOk = s.dob != null;
    final genderOk = s.gender.trim().isNotEmpty;
    final donateOk = s.wantToDonate != null;
    return dobOk && genderOk && donateOk;
  }

  void _recalc({
    String? name,
    String? phone,
    String? bloodGroup,
    String? country,
    String? city,
    DateTime? dob,
    String? gender,
    bool? wantToDonate,
    String? about,
    int? age,
  }) {
    final next = state.copyWith(
      name: name,
      phone: phone,
      bloodGroup: bloodGroup,
      country: country,
      city: city,
      dob: dob,
      gender: gender,
      wantToDonate: wantToDonate,
      about: about,
      age: age,
    );
    final isValid = next.step == 1 ? _validateStep1(next) : _validateStep2(next);
    emit(next.copyWith(isValid: isValid));
  }

  Future<void> submit() async {
    if (!state.isValid) return;
    emit(state.copyWith(submitting: true, error: null));
    await Future<void>.delayed(const Duration(milliseconds: 400));
    emit(state.copyWith(submitting: false));
  }

  int _calculateAge(DateTime dob) {
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  void reset() => emit(const ProfileSetupState());
}
