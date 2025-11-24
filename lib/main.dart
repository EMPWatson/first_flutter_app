import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
  SemanticsBinding.instance.ensureSemantics();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  Iterable<WordPair> names;
  late Iterator<WordPair> stepper = names.iterator;
  List<WordPair> wordHistory = [];
  int currentIndex = 0;
  var favourites = <WordPair>[];

  MyAppState() : names = generateWordPairs()  {
    stepper = names.iterator;
    stepper.moveNext();
    wordHistory.add(stepper.current);
    print(wordHistory);
    }

  void getNext(){
    if (currentIndex == wordHistory.length -1){
      stepper.moveNext();
      wordHistory.add(stepper.current);
    }
    currentIndex +=1;
    notifyListeners();
    }

  void getPrevious(){
    if (currentIndex - 1 >= 0){
      currentIndex -= 1;
    }
    notifyListeners();
  }

  void toggleFavourite(){
    var current = wordHistory[currentIndex];
    if (favourites.contains(current)){
      favourites.remove(current);
    } else {
      favourites.add(current);
    }
    notifyListeners();
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.wordHistory[appState.currentIndex];
    var theme = Theme.of(context);
    final style = theme.textTheme.labelLarge!.copyWith(
      color: theme.colorScheme.onPrimaryContainer,
    );

    IconData icon;
    if (appState.favourites.contains(pair)){
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                ElevatedButton.icon(
                  icon: Icon(icon),
                  label: Text("Like"),
                  onPressed: () {
                    appState.toggleFavourite();
                  },
                ),

                ElevatedButton(
                  child: Text("Previous"),
                  onPressed: () {
                    appState.getPrevious();
                  },
                ),
                    
                ElevatedButton(
                  child: Text("Next"),
                  onPressed: () {
                    appState.getNext();
                  },
                ),
              ],
            ),
          ),
          Text("word number: ${appState.currentIndex + 1}", style: style,)
        ],
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {

    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavouritesPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }


    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite),
                      label: Text('Favorites'),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}

class FavouritesPage extends StatelessWidget {
  const FavouritesPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return ListView(
      children: [
        for (var pair in appState.favourites)
          ListTile(
            title: Text(pair.asLowerCase),
            
          )
        
      ],
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      elevation: 5,
      color: theme.primaryColor,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(pair.asLowerCase, style: style, semanticsLabel: "${pair.first} ${pair.second}"),
      ),
    );
  }
}