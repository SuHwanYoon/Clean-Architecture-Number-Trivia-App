import 'dart:io';

// fixture 함수는 주어진 이름의 파일을 읽어 문자열로 반환합니다.
// 예를 들어, fixture('trivia.json')를 호출하면 test/fixtures/trivia.json 파일의 내용을 문자열로 반환합니다.
// 이함수의 목적은 테스트에서 반복적으로 사용되는 JSON 파일의 내용을 쉽게 읽어오는 것입니다.
String fixture(String name) => File('test/fixtures/$name').readAsStringSync();
