import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sehatapp/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:sehatapp/features/chat/data/chat_repository.dart';
import 'package:sehatapp/features/auth/data/user_repository.dart';

class MockChatRepository extends Mock implements ChatRepository {}

class MockUserRepository extends Mock implements IUserRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ChatCubit cubit;
  late MockChatRepository mockRepo;
  late MockUserRepository mockUserRepo;

  setUp(() {
    mockRepo = MockChatRepository();
    mockUserRepo = MockUserRepository();
    cubit = ChatCubit(mockRepo, mockUserRepo);
  });

  tearDown(() {
    cubit.close();
  });

  group('ChatCubit', () {
    test('initial state is correct', () {
      expect(cubit.state.loading, isFalse);
      expect(cubit.state.messages, isEmpty);
      expect(cubit.state.conversationId, isNull);
    });

    test('state has correct properties', () {
      final state = ChatState(
        conversationId: 'conv123',
        otherUid: 'user456',
        messages: [],
        loading: false,
      );

      expect(state.conversationId, 'conv123');
      expect(state.otherUid, 'user456');
      expect(state.loading, isFalse);
    });
  });
}
