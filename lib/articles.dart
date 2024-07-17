import 'package:http/http.dart' as http;
//import 'package:flutter/foundation.dart';
import 'dart:convert';

class NewsService {
  // future 비동기 동작, async와 무조건 세트
  Future<List<Article>> fetchArticles({int page = 1, String country = '', String category = '', String apiKey = '51d48129b8a64c06b113ef211d355f10'}) async {
    String url = 'https://newsapi.org/v2/top-headlines?';
    if(country.isEmpty){
      country = 'kr';
    }
    url += 'country=$country';
    if (category.isNotEmpty && category != 'Headlines') {
      url += '&category=$category';
    }
    if(page > 1){
      url+= '&page=$page';
    }
    url += '&apiKey=$apiKey';
    print('url : $url');
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(response.body);
      List<dynamic> body = json['articles'];
      List<Article> articles = [];
      for(var item in body){
        if(await _isUrlValid(item['urlToImage'])){
          articles.add(Article.fromJson(item));
        }
      }
      return articles;
    } else {
      //throw Exception('Failed to load articles');
      return [];
    }
  }


  Future<bool> _isUrlValid(String?  urlToImage) async {
    try{
      if(urlToImage == null || urlToImage.isEmpty){
        return false;
      }
      final response = await http.head(Uri.parse(urlToImage));
      return response.statusCode == 200;
    }catch(e){
      return false;
    }
  }

}

class Article {
  final String title;
  final String description;
  final String urlToImage;
  final String url;

  Article(
      {required this.title,
      required this.description,
      required this.urlToImage,
      required this.url});

  // 복잡한 데이터나 없는 데이터가 많을 때 factory 사용 -> 없어도 기본 생성자를 만들어서? 틀을 잡아서 넘겨준다 -> 생성자를 보장해준다
  // 싱글톤 생성자를 만들때도 일반적으로 factory 사용
  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        urlToImage: json['urlToImage'] ?? '',
        url: json['url'] ?? '');
  }
}
