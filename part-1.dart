/*
  https://ruslanspivak.com/lsbasi-part1/
*/

import 'dart:io';

enum Types {
  Integer,
  Addition,
  Substraction,
  EOF //end of file
}

void main(List<String> args) {
  while (true) {
    var source = '';
    try {
      source = stdin.readLineSync();
    } catch(e) {
      break;
    }
    var interpreter = Interpreter(source);
    var result = interpreter.expr();
    print('RESULT: ' + result.toString());
  }
}

class Token {
  // integer, addition, substraction or end of file
  Types type;
  // value of type
  dynamic value;

  Token(this.type, this.value);

  @override 
  String toString() {
    // Token(Types.Integer, 4) or Token(Types.EOF, null), ...
    return 'Token(${type}, ${value})';
  }
}

class Interpreter {
  // source code
  String source;
  // file reading position (char num)
  int pos = 0;
  Token currentToken;

  Interpreter(this.source);

  Token getNextToken() {
    /*
    lexical analizer (lexer, scanner or tokenizer)

    This method is responsible for breaking a sentence
    apart into tokens. One token at a time.
    */

    // if index > source.numberOfCharacters: return end of file token
    if (pos > source.length - 1) return Token(Types.EOF, null);

    var currentChar = source[pos];

    // check for whitespace characters and ignore them
    while (currentChar == ' ') {
      pos += 1;
      if (pos == source.length) break;
      currentChar = source[pos];
    }

    // if index > source.numberOfCharacters: return end of file token
    if (pos > source.length - 1) return Token(Types.EOF, null);

    // try to scan a list of numbers (= integer)
    var integer = '';
    while (int.tryParse(currentChar) is int) {
      integer += currentChar;
      pos += 1;
      if (pos == source.length) break;
      currentChar = source[pos];
    }
    if (integer != '') return Token(Types.Integer, int.tryParse(integer));

    // if currentChar.isPlus: return addition token
    if (currentChar == '+') {
      var token = Token(Types.Addition, '+');
      pos += 1;
      return token;
    }

    // if currentChar.isMinus: return substraction token
    if (currentChar == '-') {
      var token = Token(Types.Substraction, '-');
      pos += 1;
      return token;
    }

    // error: current char not of type addition, integer or end of file
    throw Exception('Error parsing input.\nCould not find token of type addition, integer or EOF. Current char: {$currentChar}. Current token: {$currentToken}');
  }

  void eat(Types tokenType) {
    /*
    compare the current token type with the passed token
    type and if they match then "eat" the current token
    and assign the next token to the self.current_token,
    otherwise raise an exception.
    */

    if (currentToken.type == tokenType) {
      currentToken = getNextToken();
    } else {
      throw Exception('Error parsing input.\nCurrent token {$currentToken} does not match expected token type {$tokenType}');
    }
  }

  void eatOr(List<Types> tokenTypes) {
    // expect multiple possible token types

    if (tokenTypes.contains(currentToken.type)) {
      currentToken = getNextToken();
    } else {
      throw Exception('Error parsing input.\nCurrent token {$currentToken} does not match one of exptected token types {$tokenTypes}');
    }
  }

  int expr() {
    // expression: INTEGER PLUS INTEGER
    
    // set current token to the first token taken from the input
    currentToken = getNextToken();

    var left = currentToken;
    // expect the current token to be an integer. otherwise raise error
    eat(Types.Integer);

    // operator
    var op = currentToken.type;
    eatOr([Types.Addition, Types.Substraction]);

    var right = currentToken;
    eat(Types.Integer);

    // expect the last token to be end of file. expressions like "2 + 1   5" or "32 - 4 +" are invalid
    if (currentToken.type != Types.EOF) {
      throw Exception('Error parsing input.\n Expected token to be EOF but got {$currentToken}');
    }

    /*
    after the above call the self.current_token is set to
    EOF token

    at this point INTEGER PLUS INTEGER sequence of tokens
    has been successfully found and the method can just
    return the result of adding two integers, thus
    effectively interpreting client input
    */

    // is operator of type addition? return left + right. otherwise return left - right
    var result = (op == Types.Addition) ? (left.value + right.value) : (left.value - right.value);

    return result;
  }
}
