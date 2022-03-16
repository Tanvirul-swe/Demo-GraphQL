import 'package:graphql/client.dart';
import 'package:qltest/baseurl.dart';
import 'package:qltest/error.dart';

class GraphQLUtil {
  factory GraphQLUtil() => _graphqlUtil;
  GraphQLUtil.internal();
  static final GraphQLUtil _graphqlUtil = GraphQLUtil.internal();

  static AuthLink _getBearerToken() {
    return AuthLink(
      getToken: () => 'Bearer {CoolAuthService().getAuthData()?.token}',
    );
  }

  static HttpLink get _link => HttpLink(
        baseUrl,
        defaultHeaders: <String, String>{
          'Content-Type': 'application/json',
        },
      );

  static GraphQLClient get _graphQLClient => GraphQLClient(
        link: _getBearerToken().concat(_link),
        cache: GraphQLCache(
          store: InMemoryStore(),
          partialDataPolicy: PartialDataCachePolicy.accept,
        ),
      );

  Future<Map<String, dynamic>> mutationRequest(
    MutationOptions options,
  ) async {
    try {
      final _response = await _graphQLClient.mutate(options);

      if (_response.hasException) {
        if (_response.exception!.graphqlErrors.isNotEmpty) {
          throw Failure.fromGraphQL(_response.exception!.graphqlErrors);
        }
        throw Failure(message: _response.exception.toString());
      }

      final _responseBody = _response.data;
      if (_responseBody != null && _responseBody.isEmpty) {
        return <String, dynamic>{};
      }
      return Future.value(_responseBody);
    } on Failure {
      rethrow;
    } catch (e) {
      throw Failure(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> queryRequest(
    QueryOptions options,
  ) async {
    try {
      final _response = await _graphQLClient.query(options);

      if (_response.hasException) {
        if (_response.exception!.graphqlErrors.isNotEmpty) {
          throw Failure.fromGraphQL(_response.exception!.graphqlErrors);
        }
        throw Failure(message: _response.exception.toString());
      }

      final _responseBody = _response.data;
      if (_responseBody != null && _responseBody.isEmpty) {
        return <String, dynamic>{};
      }
      return Future.value(_responseBody);
    } on Failure {
      rethrow;
    } catch (e) {
      throw Failure(message: e.toString());
    }
  }
}
