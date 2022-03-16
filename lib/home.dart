import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class Home extends StatefulWidget {
  final token;
  Home(this.token);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final String loginquery = r"""
mutation UserLogin($username:String,$password:String){
    userLogin(username:$username,password:$password){
        token
        status
        name
    }
}


""";
  final String createaccout = r"""
     mutation CreateUser(
$name: String
$username: String
$password: String

){
  createUser(
    name:$name,
    username:$username,
    password:$password,
   

  ){
    status
  }
}
   
""";
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authLink = AuthLink(
      getToken: () async => 'Bearer ${widget.token}',
    );
    final httpLink =
        HttpLink('http://65.2.19.245:3000/graphql', defaultHeaders: {});
    Link link = authLink.concat(httpLink);

    final ValueNotifier<GraphQLClient> client = ValueNotifier<GraphQLClient>(
      GraphQLClient(
        link: link,
        cache: GraphQLCache(
          store: InMemoryStore(),
        ),
      ),
    );
    return GraphQLProvider(
      client: client,
      child: Scaffold(
        body: Mutation(
          options: MutationOptions(
              document: gql(createaccout),
              /*
            variables: {
              "username": "iqbal4",
              "password": "12345678",
            },
            */
              // ignore: void_checks
              update: (GraphQLDataProxy cache, QueryResult? result) {
                return cache;
              },
              onCompleted: (dynamic resultData) {
                //print(resultData);
              }),
          builder: (
            RunMutation runMutation,
            QueryResult? result,
          ) {
            print(result);
            if (result!.hasException) {
              print('I have some problem');
            }
            return Column(
              children: [
                ElevatedButton(
                    onPressed: () {
                      runMutation({
                        'name': "Ontor",
                        'username': 'ontor123',
                        'password': '12345678',
                      });
                    },
                    child: Text('Verify')),
              ],
            );
          },
        ),
      ),
    );
  }
}
