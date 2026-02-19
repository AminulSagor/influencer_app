// import 'api_client.dart';

// class LeadManagerService {
//   LeadManagerService(this._api);

//   final ApiClient _api;

  // Future<Map<String, dynamic>> login({
  //   required String email,
  //   required String password,
  // }) async {
  //   final res = await _api.dio.post(
  //     '/auth/login',
  //     data: {'email': email, 'password': password},
  //   );
  //   if (res.data is Map<String, dynamic>) return res.data as Map<String, dynamic>;
  //   if (res.data is Map) return Map<String, dynamic>.from(res.data as Map);
  //   return const {};
  // }

//   Future<Map<String, dynamic>> createB2b(Map<String, dynamic> payload) async {
//     final res = await _api.dio.post('/b2b/create', data: payload);
//     if (res.data is Map<String, dynamic>)
//       return res.data as Map<String, dynamic>;
//     if (res.data is Map) return Map<String, dynamic>.from(res.data as Map);
//     return const {};
//   }

//   Future<Map<String, dynamic>> bulkCreateB2b(
//     List<Map<String, dynamic>> records,
//   ) async {
//     final res = await _api.dio.post(
//       '/b2b/bulk-create',
//       data: {'data': records},
//     );
//     if (res.data is Map<String, dynamic>)
//       return res.data as Map<String, dynamic>;
//     if (res.data is Map) return Map<String, dynamic>.from(res.data as Map);
//     return const {};
//   }

//   Future<Map<String, dynamic>> getB2bList({
//     int page = 1,
//     int limit = 10,
//     String? search,
//   }) async {
//     final res = await _api.dio.get(
//       '/b2b',
//       queryParameters: {
//         'page': page,
//         'limit': limit,
//         if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
//       },
//     );
//     if (res.data is Map<String, dynamic>)
//       return res.data as Map<String, dynamic>;
//     if (res.data is Map) return Map<String, dynamic>.from(res.data as Map);
//     return const {};
//   }

//   Future<Map<String, dynamic>> searchB2b({
//     required String query,
//     int page = 1,
//     int limit = 10,
//   }) async {
//     final res = await _api.dio.get(
//       '/b2b/search',
//       queryParameters: {'query': query, 'page': page, 'limit': limit},
//     );
//     if (res.data is Map<String, dynamic>)
//       return res.data as Map<String, dynamic>;
//     if (res.data is Map) return Map<String, dynamic>.from(res.data as Map);
//     return const {};
//   }

//   Future<Map<String, dynamic>> getB2bById(String id) async {
//     final res = await _api.dio.get('/b2b/$id');
//     if (res.data is Map<String, dynamic>)
//       return res.data as Map<String, dynamic>;
//     if (res.data is Map) return Map<String, dynamic>.from(res.data as Map);
//     return const {};
//   }

//   Future<Map<String, dynamic>> updateB2b({
//     required String id,
//     required Map<String, dynamic> payload,
//   }) async {
//     final res = await _api.dio.put('/b2b/$id', data: payload);
//     if (res.data is Map<String, dynamic>)
//       return res.data as Map<String, dynamic>;
//     if (res.data is Map) return Map<String, dynamic>.from(res.data as Map);
//     return const {};
//   }

//   Future<void> deleteB2b(String id) async {
//     await _api.dio.delete('/b2b/$id');
//   }

//   Future<void> exportB2b() async {
//     await _api.dio.get('/b2b/export');
//   }
// }
