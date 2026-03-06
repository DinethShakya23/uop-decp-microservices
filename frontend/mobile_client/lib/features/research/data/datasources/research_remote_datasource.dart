import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../models/research_model.dart';

abstract class ResearchRemoteDatasource {
  Future<List<ResearchModel>> getResearch({String? category, String? search});
  Future<ResearchModel> getById(int id);
  Future<ResearchModel> create(Map<String, dynamic> data);
  Future<ResearchModel> update(int id, Map<String, dynamic> data);
  Future<void> delete(int id);
  Future<void> download(int id);
}

class ResearchRemoteDatasourceImpl implements ResearchRemoteDatasource {
  final Dio _dio;
  ResearchRemoteDatasourceImpl(this._dio);

  @override
  Future<List<ResearchModel>> getResearch(
      {String? category, String? search}) async {
    try {
      final resp = await _dio.get(ApiConstants.research, queryParameters: {
        if (category != null) 'category': category,
        if (search != null) 'search': search
      });
      final list = resp.data as List? ?? [];
      return list
          .map((e) => ResearchModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  @override
  Future<ResearchModel> getById(int id) async {
    try {
      final resp = await _dio.get('${ApiConstants.research}/$id');
      return ResearchModel.fromJson(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  @override
  Future<ResearchModel> create(Map<String, dynamic> data) async {
    try {
      final resp = await _dio.post(ApiConstants.research, data: data);
      return ResearchModel.fromJson(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  @override
  Future<ResearchModel> update(int id, Map<String, dynamic> data) async {
    try {
      final resp = await _dio.put('${ApiConstants.research}/$id', data: data);
      return ResearchModel.fromJson(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  @override
  Future<void> delete(int id) async {
    try {
      await _dio.delete('${ApiConstants.research}/$id');
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  @override
  Future<void> download(int id) async {
    try {
      await _dio.post('${ApiConstants.research}/$id/download');
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  Never _handleError(DioException e) {
    if (e.response?.statusCode == 401) throw const AuthException();
    if (e.response?.statusCode == 403) throw const ForbiddenException();
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.unknown) {
      throw const NetworkException();
    }
    throw ServerException(e.response?.data?['message']?.toString() ?? 'Error');
  }
}

final researchDatasourceProvider = Provider<ResearchRemoteDatasource>((ref) {
  return ResearchRemoteDatasourceImpl(ref.watch(dioProvider));
});

// ---- Provider ----
class ResearchState {
  final List<ResearchModel> items;
  final bool isLoading;
  final String? error;
  const ResearchState(
      {this.items = const [], this.isLoading = false, this.error});

  ResearchState copyWith(
          {List<ResearchModel>? items,
          bool? isLoading,
          String? error,
          bool clearError = false}) =>
      ResearchState(
          items: items ?? this.items,
          isLoading: isLoading ?? this.isLoading,
          error: clearError ? null : (error ?? this.error));
}

class ResearchNotifier extends Notifier<ResearchState> {
  @override
  ResearchState build() {
    _init();
    return const ResearchState();
  }

  Future<void> _init() async {
    await loadResearch();
  }

  Future<void> loadResearch({String? category, String? search}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final items = await ref
          .read(researchDatasourceProvider)
          .getResearch(category: category, search: search);
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> create(Map<String, dynamic> data) async {
    try {
      final item = await ref.read(researchDatasourceProvider).create(data);
      state = state.copyWith(items: [item, ...state.items]);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> delete(int id) async {
    try {
      await ref.read(researchDatasourceProvider).delete(id);
      state =
          state.copyWith(items: state.items.where((r) => r.id != id).toList());
      return true;
    } catch (_) {
      return false;
    }
  }
}

final researchProvider =
    NotifierProvider<ResearchNotifier, ResearchState>(ResearchNotifier.new);

final singleResearchProvider =
    FutureProvider.family<ResearchModel, int>((ref, id) {
  return ref.watch(researchDatasourceProvider).getById(id);
});
