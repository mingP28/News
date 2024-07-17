import 'package:flutter/material.dart';
import 'articles.dart';
import 'dart:developer' as developer; // print에 해당하는 log 사용가능
import 'package:url_launcher/url_launcher.dart';

class ArticleCard extends StatelessWidget{

  late final Article article;
  ArticleCard({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    //developer.log('image url : ${article.urlToImage}');
    return GestureDetector(
      //onTap: () => developer.log('URL : ${article.url}'),
      onTap: () => _launchUrl(article.url),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // top
          children: [
            (article.urlToImage.isNotEmpty) // no image -> 대체사진 필요
            ? Image.network(article.urlToImage, width: double.infinity, height: 350, fit: BoxFit.cover) 
            : Image.asset('assets/images/no_image.png', width: double.infinity, height: 350, fit: BoxFit.cover), 
            Padding(
              padding: const EdgeInsets.all(8), 
              child: Text(article.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            )),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(article.description,
              style: const TextStyle(fontSize: 15),
              )),
          ],
         ),
      ),
    );
  }
  

  _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    //developer.log('URL : ${article.url}');
    if(await canLaunchUrl(uri)){
      await launchUrl(uri);
    }else{
      throw 'Could not launch $url';
    }
  }
  
}