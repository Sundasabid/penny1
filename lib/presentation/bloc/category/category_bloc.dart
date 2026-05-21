import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/category_repository.dart';
import '../../../domain/entities/category.dart';
import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository _categoryRepository;
  StreamSubscription<List<CategoryEntity>>? _categorySubscription;

  CategoryBloc({required CategoryRepository categoryRepository})
    : _categoryRepository = categoryRepository,
      super(const CategoryState()) {
    on<LoadCategoriesRequested>(_onLoadCategories);
    on<AddCategoryRequested>(_onAddCategory);
    on<UpdateCategoryRequested>(_onUpdateCategory);
    on<DeleteCategoryRequested>(_onDeleteCategory);
    on<ResetCategoriesRequested>(_onResetCategories);
    on<CategoriesUpdated>(_onCategoriesUpdated);
    on<CategoriesError>(_onCategoriesError);
  }

  Future<void> _onLoadCategories(
    LoadCategoriesRequested event,
    Emitter<CategoryState> emit,
  ) async {
    emit(state.copyWith(status: CategoryStatus.loading));
    await _categorySubscription?.cancel();
    _categorySubscription = _categoryRepository.getCategories().listen(
      (categories) => add(CategoriesUpdated(categories)),
      onError: (error) => add(CategoriesError(error.toString())),
    );
  }

  void _onCategoriesUpdated(
    CategoriesUpdated event,
    Emitter<CategoryState> emit,
  ) {
    emit(
      state.copyWith(
        status: CategoryStatus.loaded,
        categories: event.categories,
      ),
    );
  }

  void _onCategoriesError(CategoriesError event, Emitter<CategoryState> emit) {
    emit(
      state.copyWith(status: CategoryStatus.error, errorMessage: event.message),
    );
  }

  Future<void> _onAddCategory(
    AddCategoryRequested event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      await _categoryRepository.addCategory(event.category);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onUpdateCategory(
    UpdateCategoryRequested event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      await _categoryRepository.updateCategory(event.category);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onDeleteCategory(
    DeleteCategoryRequested event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      await _categoryRepository.deleteCategory(event.id);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onResetCategories(
    ResetCategoriesRequested event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      await _categoryRepository.resetToDefaults();
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  // Internal events
  @override
  void onEvent(CategoryEvent event) {
    super.onEvent(event);
  }

  // Need to register handlers for internal events if I use them,
  // but better to just use a custom event or make them public if valid.
  // Actually, I should add these internal events to the event file or make them private classes here if I want to use `add`.
  // For simplicity and cleaner bloc pattern let's add them to the main event class but hide them if possible, or just public.
  // Wait, I can't add private classes to public standard blocs easily without casting.
  // Let's just make `_CategoriesUpdated` a public event `CategoriesUpdated` in the event file but keep it internal to logic.
}

// Add these to category_event.dart (I will perform a multi-file edit or just fix it now)
// Actually I will just fix category_event.dart to include these, or handle subscription differently.
