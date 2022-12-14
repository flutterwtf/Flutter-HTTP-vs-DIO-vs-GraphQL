import 'package:client/domain/entities/post/post.dart';
import 'package:client/domain/entities/user/user.dart';
import 'package:client/domain/interactors/post_interactor.dart';
import 'package:client/domain/interactors/user_interactor.dart';
import 'package:client/presentation/base/base_state_notifier.dart';
import 'package:client/presentation/di/injector.dart';
import 'package:client/presentation/pages/post_constructor/post_constructor_state.dart';
import 'package:client/presentation/tools/error_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final postConstructorProvider =
    StateNotifierProvider<PostConstructorStateNotifier, PostConstructorState>((ref) {
  return PostConstructorStateNotifier();
});

class PostConstructorStateNotifier extends BaseStateNotifier<PostConstructorState> {
  static final _initialValue = PostConstructorState(
    isButtonActive: false,
    showServerErrorMessage: false,
  );

  late final PostInteractor _postInteractor;
  late final User _user;

  PostConstructorStateNotifier() : super(_initialValue) {
    _postInteractor = i.get();
    _user = i.get<UserInteractor>().user;
  }

  Future<void> addPost({
    required String title,
    required String text,
    required Function onSuccess,
  }) async {
    final post = Post(
      id: '0',
      userId: _user.id,
      authorName: _user.name,
      text: text,
      title: title,
      date: DateTime.now(),
    );
    return launchRetrieveResult(
      () async {
        await _postInteractor.addPost(post);
        state = state.copyWith(isButtonActive: false);
        onSuccess();
      },
      errorHandler: (e) => _openErrorDialog(),
    );
  }

  Future<void> editPost({
    required String postId,
    required String title,
    required String text,
    required Function onSuccess,
  }) async {
    final post = Post(
      id: postId,
      userId: _user.id,
      authorName: _user.name,
      text: text,
      title: title,
      date: DateTime.now(),
    );
    return launchRetrieveResult(
      () async {
        await _postInteractor.editPost(post);
        state = state.copyWith(isButtonActive: false);
        onSuccess();
      },
      errorHandler: (e) => _openErrorDialog(),
    );
  }

  void setButtonActive(String title, String text) =>
      state = state.copyWith(isButtonActive: title.isNotEmpty && text.isNotEmpty);

  void _openErrorDialog() => state.copyWith(showServerErrorMessage: true);

  void closeErrorDialog() {
    pop();
    state.copyWith(showServerErrorMessage: false);
  }
}
