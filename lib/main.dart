import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

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
  @override
  Widget build(BuildContext context) {
    final HttpLink httpLink = HttpLink("https://rickandmortyapi.com/graphql");

    final ValueNotifier<GraphQLClient> client = ValueNotifier<GraphQLClient>(
      GraphQLClient(
          link: httpLink as Link, cache: GraphQLCache(store: HiveStore())),
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
  final String query = r"""
                   query character($id:ID!){
  character(id:$id){
    image
    name
    gender
    status
  }
}
                  """;

  TextEditingController controller = TextEditingController(text: '1');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("GraphlQL Client"),
        ),
        body: Column(
          children: [
            TextField(
              controller: controller,
              onChanged: (value) {
                setState(() {
                  debugPrint(value);
                });
              },
              decoration: InputDecoration(),
            ),
            ElevatedButton(onPressed: () {}, child: Text('Submit ID')),
            Query(
                options: QueryOptions(document: gql(query), variables: {
                  'id': int.parse(controller.text),
                }),
                builder: (QueryResult result,
                    {VoidCallback? refetch, FetchMore? fetchMore}) {
                  if (result.isLoading) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (result.hasException) {
                    return Text('Something wqrrong');
                  }
                  if (result.data == null) {
                    Text('Data empty');
                  }
                  return Column(
                    children: [
                      Container(
                        height: 200,
                        child:
                            Image.network(result.data!['character']['image']),
                      ),
                      Text("Name : ${result.data!['character']['name']}"),
                      Text("Gender : ${result.data!['character']['gender']}"),
                      Text("Status : ${result.data!['character']['status']}"),
                    ],
                  );
                }),
          ],
        ));
  }
}
