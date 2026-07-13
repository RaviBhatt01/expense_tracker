part of 'category_cubit.dart';

@freezed
class CategoryState with _$CategoryState {
  const factory CategoryState.initial() = CategoryInitial;
  const factory CategoryState.loading() = CategoryLoading;
  const factory CategoryState.loaded({required List<Category> categories}) =
      CategoryLoaded;
  const factory CategoryState.error({required String message}) = CategoryError;
}
