import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sehatapp/core/network/network_status_cubit.dart';
import 'package:sehatapp/core/services/network_service.dart';

class MockNetworkService extends Mock implements NetworkService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late NetworkStatusCubit cubit;
  late MockNetworkService mockNetworkService;

  setUp(() {
    mockNetworkService = MockNetworkService();

    // Mock the connectivityStream to return a stream
    when(
      () => mockNetworkService.connectivityStream,
    ).thenAnswer((_) => Stream.value(true));

    // Mock isConnected for retry test
    when(() => mockNetworkService.isConnected).thenAnswer((_) async => true);

    cubit = NetworkStatusCubit(mockNetworkService);
  });

  tearDown(() {
    cubit.close();
  });

  group('NetworkStatusCubit', () {
    test('initial state is NetworkChecking', () {
      // Constructor starts with NetworkChecking
      expect(cubit.state, isA<NetworkStatus>());
    });

    test('state types are correct', () {
      expect(NetworkConnected(), isA<NetworkStatus>());
      expect(NetworkDisconnected(), isA<NetworkStatus>());
      expect(NetworkChecking(), isA<NetworkStatus>());
    });

    test('retry calls network service', () async {
      await cubit.retry();
      verify(() => mockNetworkService.isConnected).called(1);
    });
  });
}
