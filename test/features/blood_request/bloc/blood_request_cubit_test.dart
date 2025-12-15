import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sehatapp/features/blood_request/bloc/blood_request_cubit.dart';
import 'package:sehatapp/features/blood_request/data/blood_request_repository.dart';

class MockBloodRequestRepository extends Mock
    implements BloodRequestRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late BloodRequestCubit cubit;
  late MockBloodRequestRepository mockRepo;

  setUp(() {
    mockRepo = MockBloodRequestRepository();
    cubit = BloodRequestCubit(mockRepo);
  });

  tearDown(() {
    cubit.close();
  });

  group('BloodRequestCubit', () {
    test('initial state has loading false', () {
      expect(cubit.state.loading, isFalse);
      expect(cubit.state.items, isEmpty);
    });

    test('start loads blood requests', () async {
      // Setup mock
      when(
        () => mockRepo.streamRequests(
          bloodGroup: any(named: 'bloodGroup'),
          excludeUid: any(named: 'excludeUid'),
        ),
      ).thenAnswer((_) => Stream.value([]));

      // Act
      cubit.start();

      // Wait for stream to emit
      await Future.delayed(Duration(milliseconds: 100));

      // Assert
      expect(cubit.state.loading, isFalse);
      verify(
        () => mockRepo.streamRequests(
          bloodGroup: any(named: 'bloodGroup'),
          excludeUid: any(named: 'excludeUid'),
        ),
      ).called(1);
    });

    test('retry calls start', () async {
      // Setup mock
      when(
        () => mockRepo.streamRequests(
          bloodGroup: any(named: 'bloodGroup'),
          excludeUid: any(named: 'excludeUid'),
        ),
      ).thenAnswer((_) => Stream.value([]));

      // Act
      cubit.retry();

      // Wait for stream to emit
      await Future.delayed(Duration(milliseconds: 100));

      // Assert
      expect(cubit.state.loading, isFalse);
    });
  });
}
