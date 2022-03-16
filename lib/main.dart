import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:qltest/home.dart';

Future<void> main() async {
  await initHiveForFlutter();
  runApp(MaterialApp(
    home: MyApp(),
    title: 'GQL App',
  ));
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String token =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6ImlxYmFsNCIsInJvbGUiOiJhZ2VudCIsImlkIjoxLCJuYW1lIjoiTWQgSXFiYWwgSG9zc2FpbiIsImltYWdlIjoiaHR0cHM6Ly9hdW5rdXIuczMuYXAtc291dGgtMS5hbWF6b25hd3MuY29tL2Zhcm1lcnMvaW1hZ2UtMTY0NDgyNTI2Mzg2Ny5qcGciLCJpYXQiOjE2NDc0MjM0MjMsImV4cCI6MTY0NzQyNzAyM30.IeKXcYxaO-N484v242u6gF_MP_rCk7tO20qkTQTQ4uA';

  @override
  Widget build(BuildContext context) {
    final httpLink = HttpLink(
      'http://65.2.19.245:3000/graphql',
    );
    final authLink = AuthLink(
      getToken: () async => 'Bearer $token',
    );

    Link link = authLink.concat(httpLink);

    final ValueNotifier<GraphQLClient> client = ValueNotifier<GraphQLClient>(
      GraphQLClient(
          link: link,
          cache: GraphQLCache(
            store: HiveStore(),
          )),
    );
    return GraphQLProvider(
      client: client,
      child: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String query = """query{
    getUnion{
      name
      }
    }""";

  final String loginquery = r"""
mutation UserLogin($username:String,$password:String){
    userLogin(username:$username,password:$password){
        token
        status
        name
    }
}


""";
  String? token1;
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordControler = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("GraphlQL Client"),
      ),
      //get all union value for API
      /*
      body: Query(
        options: QueryOptions(document: gql(query)),
        builder: (QueryResult result,
            {VoidCallback? refetch, FetchMore? fetchMore}) {
          if (result.hasException) {
            return Text('Something wrrong');
          }
          if (result.isLoading) {
            return CircularProgressIndicator();
          }
          return ListView.builder(
              itemCount: result.data!['getUnion'].length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title:
                      Text(result.data!['getUnion'][index]['name'].toString()),
                );
              });
        },
      ),
      */

      body: Mutation(
        options: MutationOptions(
            document: gql(loginquery),
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
          print(result!.data);
          if (result.hasException) {
            print('I have some problem');
          }

          return Column(
            children: [
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(label: Text('Username')),
              ),
              TextField(
                controller: _passwordControler,
                decoration: const InputDecoration(label: Text('Password')),
              ),
              ElevatedButton(
                  onPressed: () async {
                    runMutation({
                      'username': _usernameController.text,
                      'password': _passwordControler.text,
                    });
                    if (result.data != null) {
                      final status =
                          result.data!['userLogin']['status'].toString();
                      if (status == 'SUCCESS') {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Home(token1)));
                      }
                    }
                  },
                  child: Text('Submited')),
            ],
          );
        },
      ),
    );
  }
}
