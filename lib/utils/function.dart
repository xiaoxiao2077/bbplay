import 'package:flutter/material.dart';

regCate(String origin) {
  String str = origin;
  RegExp exp = RegExp('<[^>]*>([^<]*)</[^>]*>');
  Iterable<Match> matches = exp.allMatches(origin);
  for (Match match in matches) {
    str = match.group(1)!;
  }
  return str;
}

regTitle(String origin) {
  RegExp exp = RegExp('<[^>]*>([^<]*)</[^>]*>');
  List res = [];
  origin.splitMapJoin(exp, onMatch: (Match match) {
    String matchStr = match[0]!;
    Map map = {'type': 'em', 'text': regCate(matchStr)};
    res.add(map);
    return regCate(matchStr);
  }, onNonMatch: (String str) {
    if (str != '') {
      str = decodeHtmlEntities(str);
      Map map = {'type': 'text', 'text': str};
      res.add(map);
    }
    return str;
  });
  return res;
}

String decodeHtmlEntities(String title) {
  return title
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&#34;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll('&quot;', '"')
      .replaceAll('&apos;', "'")
      .replaceAll('&nbsp;', " ")
      .replaceAll('&amp;', "&")
      .replaceAll('&#x27;', "'");
}

Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String content,
  String confirmText = '确定',
  String cancelText = '取消',
}) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          TextButton(
            child: Text(cancelText,
                style: const TextStyle(color: Colors.redAccent)),
            onPressed: () {
              Navigator.of(context).pop(false); // 返回 false
            },
          ),
          TextButton(
            child:
                Text(confirmText, style: const TextStyle(color: Colors.black)),
            onPressed: () {
              Navigator.of(context).pop(true); // 返回 true
            },
          ),
        ],
      );
    },
  ).then((value) => value ?? false); // 如果返回值为 null，则默认返回 false
}
