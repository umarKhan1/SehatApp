import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sehatapp/features/post_request/bloc/create_post_cubit.dart';
import 'package:sehatapp/features/post_request/data/post_repository.dart';

class MockPostRepository extends Mock implements PostRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CreatePostCubit cubit;
  late MockPostRepository mockRepo;

  setUpAll(() {
    // Register fallback values for any() matchers
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    mockRepo = MockPostRepository();
    cubit = CreatePostCubit(repo: mockRepo);
  });

  tearDown(() {
    cubit.close();
  });

  group('CreatePostCubit', () {
    test('initial state has loading false', () {
      expect(cubit.state.loading, isFalse);
      expect(cubit.state.error, isNull);
      expect(cubit.state.postId, isNull);
    });

    test('state has correct properties', () {
      final state = CreatePostState(
        loading: true,
        postId: 'post123',
        error: 'Some error',
      );

      expect(state.loading, isTrue);
      expect(state.postId, 'post123');
      expect(state.error, 'Some error');
    });
  });
}
