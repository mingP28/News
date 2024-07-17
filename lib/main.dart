import 'package:flutter/material.dart';
import 'package:news_api/article_card.dart';
import 'articles.dart';
import 'settings.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Flutter Demo",
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const NewsPage(),
    );
  }
}

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  State<StatefulWidget> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  late Future<List<Article>> futureArticles;
  final List<Article> _articles = [];
  final ScrollController _scrollControlller = ScrollController();
  int _currentPage = 1;
  String _country = 'kr';
  String _category = '';
  bool _isLoadingMore = false;
  List<Map<String, String>> items = [
      {'title': 'Korea', 'image': 'assets/images/kr.jpg', 'code': 'kr'},
      {'title': 'United States', 'image': 'assets/images/us.png', 'code': 'us'},
      {'title': 'Japan', 'image': 'assets/images/jap.jpg', 'code': 'jp'},
  ];
  String countryImage = 'assets/images/kr.jpg';

  final List<Map<String, String>> categories = [
    {'title': 'Headlines'},
    {'title': 'Business'},
    {'title': 'Technology'},
    {'title': 'Entertainment'},
    {'title': 'Sports'},
    {'title': 'Science'},
    {'title': 'Health'},
  ];

  @override
  void initState() {
    super.initState();
    futureArticles = NewsService().fetchArticles();
    futureArticles.then((articles) {
      setState(() => _articles.addAll(articles));
    });

    _scrollControlller.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollControlller.dispose();
    super.dispose();
  }

  void _onCountryTap({String country = ''}) {
    setState(() {
      _articles.clear();
      _currentPage = 1;
      futureArticles =
          NewsService().fetchArticles(country: country, category: _category);
      futureArticles.then((articles) {
        setState(() => _articles.addAll(articles));
        _country = country;
        countryImage = items.firstWhere((item) => item['code'] == country)['image']!;
      });
    });
  }

  void _onCategoryTap({String category = ''}) {
    setState(() {
      _articles.clear();
      _currentPage = 1;
      futureArticles =
          NewsService().fetchArticles(category: category, country: _country);
      futureArticles.then((articles) {
        setState(() => _articles.addAll(articles));
        _category = category;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    // 어플리케이션의 정보를 담은 context -> 디자인 통일성을 할 수 있으
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "News",
          style: TextStyle(
              fontSize: 20, color: Color.fromARGB(255, 255, 255, 255)),
        ), // const로 넘기는게 속도가 빠름 -> const 로 반환해주는게 좋다고 권장하려곡 파란줄
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      drawer: Drawer(
        child: ListView(padding: EdgeInsets.zero, children: [
          const DrawerHeader(
            decoration: BoxDecoration(
                color: Colors.blue,
                image: DecorationImage(
                    image: AssetImage('assets/images/news.jpg'),
                    fit: BoxFit.cover)),
            child: Column(
              children: [
                Padding(padding: EdgeInsets.only(top: 90)),
                Text('News Categories',
                    style: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0), fontSize: 22)),
              ],
            ),
          ),
          ...categories.map((category) => ListTile(
              title: Text(category['title']!),
              onTap: () {
                _onCategoryTap(category: category['title']!);
                Navigator.pop(context);
              })),
          // ListTile(
          //     title: const Text('Headlines'),
          //     onTap: () {
          //       _onCategoryTap();
          //       Navigator.pop(context);
          //     }),
          // ListTile(
          //     title: const Text('Business'),
          //     onTap: () {
          //       _onCategoryTap(category: 'Business');
          //       Navigator.pop(context);
          //     }),
          // ListTile(
          //     title: const Text('Technology'),
          //     onTap: () {
          //       _onCategoryTap(category: 'Technology');
          //       Navigator.pop(context);
          //     }),
          // ListTile(
          //     title: const Text('Entertainment'),
          //     onTap: () {
          //       _onCategoryTap(category: 'Entertainment');
          //       Navigator.pop(context);
          //     }),
          // ListTile(
          //     title: const Text('Sports'),
          //     onTap: () {
          //       _onCategoryTap(category: 'Sports');
          //       Navigator.pop(context);
          //     }),
          // ListTile(
          //     title: const Text('Science'),
          //     onTap: () {
          //       _onCategoryTap(category: 'Science');
          //       Navigator.pop(context);
          //     }),
          // ListTile(
          //     title: const Text('Health'),
          //     onTap: () {
          //       _onCategoryTap(category: 'Health');
          //       Navigator.pop(context);
          //     }),
        ]),
      ),
      body: FutureBuilder<List<Article>>(
        future: futureArticles,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No Data'));
          } else {
            return ListView.builder(
                controller: _scrollControlller,
                itemCount: _articles.length + (_isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _articles.length) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final article = _articles[index];
                  return ArticleCard(
                      article: article, key: ValueKey(article.title));
                });
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(items: [
        BottomNavigationBarItem(
            icon: Image.asset(
              countryImage,
              width: 24,
              height: 24,
            ),
            label: 'Country'),
        const BottomNavigationBarItem(
            icon: const Icon(Icons.search), label: "Search"),
        const BottomNavigationBarItem(
            icon: const Icon(Icons.settings), label: "Settings"),
      ], onTap: ((value) => _onNavItemTap(value, context))),
    );
  }

  void _scrollListener() {
    if (_scrollControlller.position.extentAfter < 200 && !_isLoadingMore) {
      setState(() {
        _isLoadingMore = true;
      });
      _loadMoreArticles();
    }
  }

  Future<void> _loadMoreArticles() async {
    // 인터넷 왓다가는 건 무조건 async
    _currentPage++;
    List<Article> articles = await NewsService().fetchArticles(
        page: _currentPage, category: _category, country: _country);
    setState(() {
      _articles.addAll(articles);
      _isLoadingMore = false;
    });
  }

  void _showModalBottomSheet(BuildContext context) {
    // List<Map<String, String>> items = [
    //   {'title': 'Korea', 'image': 'assets/images/kr.jpg', 'code': 'kr'},
    //   {'title': 'United States', 'image': 'assets/images/us.png', 'code': 'us'},
    //   {'title': 'Japan', 'image': 'assets/images/jap.jpg', 'code': 'jp'},
    // ];

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          width: MediaQuery.of(context).size.width,
          height: 200,
          color: Colors.white,
          child: GridView.count(
            crossAxisCount: 3,
            crossAxisSpacing: 4.0,
            mainAxisSpacing: 4.0,
            children: List.generate(items.length, (index) {
              var item = items[index];
              return Container(
                color: Colors.white,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _onCountryTap(country: item['code']!);
                  },
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          item['image']!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                        Text(item['title']!)
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  // void _showModalBottomSheet(BuildContext context) {
  //   List<Map<String, String>> items = [
  //     {'title': 'Korea', 'image': 'assets/images/kr.jpg', 'code': 'kr'},
  //     {'title': 'United States', 'image': 'assets/images/us.png', 'code': 'us'},
  //     {'title': 'Japan', 'image': 'assets/images/jap.jpg', 'code': 'jp'},
  //   ];
  //   // 001 159

  //   showModalBottomSheet(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return Container(
  //             width: MediaQuery.of(context).size.width,
  //             height: 200,
  //             color: Colors.white,
  //             child: GridView.count(
  //                 crossAxisCount: 3,
  //                 crossAxisSpacing: 4.0,
  //                 mainAxisSpacing: 4.0,
  //                 children: [
  //                   // ...List.generate
  //                   Container(
  //                       color: Colors.white,
  //                       child: GestureDetector(
  //                           onTap: () {
  //                             Navigator.pop(context);
  //                             _onCountryTap(country: '');
  //                           },
  //                           child: Center(
  //                             child: Column(
  //                               mainAxisAlignment: MainAxisAlignment.center,
  //                               children: [
  //                                 Image.asset('assets/images/kr.jpg',
  //                                     width: 50, height: 50, fit: BoxFit.cover),
  //                                 Text('Korea')
  //                               ],
  //                             ),
  //                           ))),
  //                   Container(
  //                       color: Colors.white,
  //                       child: GestureDetector(
  //                           onTap: () {
  //                             Navigator.pop(context);
  //                             _onCountryTap(country: 'us');
  //                           },
  //                           child: Center(
  //                             child: Column(
  //                               mainAxisAlignment: MainAxisAlignment.center,
  //                               children: [
  //                                 Image.asset('assets/images/us.png',
  //                                     width: 50, height: 50, fit: BoxFit.cover),
  //                                 Text('United States')
  //                               ],
  //                             ),
  //                           ))),
  //                   Container(
  //                       color: Colors.white,
  //                       child: GestureDetector(
  //                           onTap: () {
  //                             Navigator.pop(context);
  //                             _onCountryTap(country: 'jp');
  //                           },
  //                           child: Center(
  //                             child: Column(
  //                               mainAxisAlignment: MainAxisAlignment.center,
  //                               children: [
  //                                 Image.asset('assets/images/jap.jpg',
  //                                     width: 50, height: 50, fit: BoxFit.cover),
  //                                 Text('Japan')
  //                               ],
  //                             ),
  //                           )))
  //                 ]));
  //       });
  // }

  _onNavItemTap(int value, BuildContext context) {
    print('Selected Index: $value');

    switch (value) {
      case 0:
        _showModalBottomSheet(context);
        break;
      case 1:
        break;
      case 2:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => SettingsPage()));
        break;
    }
  }
}
