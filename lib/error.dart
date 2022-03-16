import 'package:graphql/client.dart';

class Failure implements Exception {
  Failure({
    required this.message,
  });

  final String message;

  factory Failure.fromGraphQL(List<GraphQLError> errors) {
    List<String> messages = [];

    for (GraphQLError error in errors) {
      messages.add(error.message);
    }

    return Failure(
      message: messages.toString().replaceAll('[', '').replaceAll(']', ''),
    );
  }
}
