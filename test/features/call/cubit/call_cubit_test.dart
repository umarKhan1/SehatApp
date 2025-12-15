import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sehatapp/features/call/presentation/cubit/call_cubit.dart';
import 'package:sehatapp/features/call/domain/repositories/call_repository.dart';
import 'package:sehatapp/features/chat/data/chat_repository.dart';

class MockCallRepository extends Mock implements ICallRepository {}

class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CallCubit cubit;
  late MockCallRepository mockCallRepo;
  late MockChatRepository mockChatRepo;

  setUp(() {
    mockCallRepo = MockCallRepository();
    mockChatRepo = MockChatRepository();
    cubit = CallCubit(mockCallRepo, chatRepo: mockChatRepo);
  });

  tearDown(() {
    cubit.close();
  });

  group('CallCubit - Video/Audio Calls', () {
    test('initial state is idle', () {
      expect(cubit.state.phase, CallPhase.idle);
      expect(cubit.state.isMuted, isFalse);
      expect(cubit.state.isSpeakerOn, isTrue);
    });

    test('toggle mute changes mute state', () {
      cubit.toggleMute();
      expect(cubit.state.isMuted, isTrue);

      cubit.toggleMute();
      expect(cubit.state.isMuted, isFalse);
    });

    test('toggle speaker changes speaker state', () {
      cubit.toggleSpeaker();
      expect(cubit.state.isSpeakerOn, isFalse);

      cubit.toggleSpeaker();
      expect(cubit.state.isSpeakerOn, isTrue);
    });

    test('state has correct properties', () {
      final state = CallState(
        phase: CallPhase.idle,
        isMuted: true,
        isSpeakerOn: false,
      );

      expect(state.phase, CallPhase.idle);
      expect(state.isMuted, isTrue);
      expect(state.isSpeakerOn, isFalse);
    });
  });
}
