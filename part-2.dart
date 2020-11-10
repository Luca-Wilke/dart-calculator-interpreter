/*
  https://ruslanspivak.com/lsbasi-part2/
*/

import 'dart:io';

enum Types {
  Integer,
  Addition,
  Substraction,
  Multiplication,
  Division,
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
    interpreter.expr();
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
  // current token instance
  Token currentToken;
  String currentChar;

  Interpreter(this.source) {
    currentChar = source[pos];
  }

  void advance() {
    // Advance the 'pos' pointer and set the 'current_char' variable

    pos += 1;
    // if pos > file length: current char = null. else: pos in source
    currentChar = (pos > source.length - 1) ? (null) : (source[pos]);
  }

  void skipWhitespace() {
    //if char is whitespace: increase file reading position. check again.
    while (currentChar != null && currentChar == ' ') {
      advance();
    };
  }

  int scanInteger() {
    // Return a (multidigit) integer consumed from the input.

    var result = '';
    // if char is integer: append char to result. increase position. check again. otherwise: return result to int
    while (currentChar != null && int.tryParse(currentChar) is int) {
      result += currentChar;
      advance();
    }
    return int.tryParse(result);
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

  Token getNextToken() {
    /*
    lexical analizer (lexer, scanner or tokenizer)

    This method is responsible for breaking a sentence
    apart into tokens. One token at a time.
    */

    while (currentChar != null) {

      if (currentChar == ' ') {
        skipWhitespace();
        continue;
      }

      if (int.tryParse(currentChar) is int) {
        return Token(Types.Integer, scanInteger());
      }

      if (currentChar == '+') {
        advance();
        return Token(Types.Addition, '+');
      }

      if (currentChar == '-') {
        advance();
        return Token(Types.Substraction, '-');
      }

      if (currentChar == '*') {
        advance();
        return Token(Types.Multiplication, '-');
      }

      if (currentChar == '/') {
        advance();
        return Token(Types.Division, '/');
      }

      throw Exception('Error parsing input.\nCould not find any token.\nCurrent char: {$currentChar}\nCurrent token: {$currentToken}');

    }

    //end of file
    return Token(Types.EOF, null);
  }

  dynamic expr({dynamic leftValue}) {
    // expression: INTEGER PLUS INTEGER

    var left;

    if (leftValue == null) {
      // first expression
      // set current token to the first token taken from the input
      currentToken = getNextToken();
      
      left = currentToken.value;
      // expect the current token to be an integer. otherwise raise error
      eat(Types.Integer);
    } else {
      left = leftValue;
    }

    // operator
    var op = currentToken.type;
    eatOr([Types.Addition, Types.Substraction, Types.Multiplication, Types.Division]);

    var right = currentToken.value;
    eat(Types.Integer);

    /*
    after the above call the self.current_token is set to
    EOF token

    at this point INTEGER PLUS INTEGER sequence of tokens
    has been successfully found and the method can just
    return the result of adding two integers, thus
    effectively interpreting client input
    */

    dynamic result;

    switch (op) {
      case Types.Addition:
        result = left + right;
        break;
      case Types.Substraction:
        result = left - right;
        break;
      case Types.Multiplication:
        result = left * right;
        break;
      case Types.Division: 
        result = left / right;
        break;
      default:
        throw Exception('Error parsing input.\nInvalid operator.');
    }

    // expect the last token to be end of file. expressions like "2 + 1   5" or "32 - 4 +" are invalid
    if (currentToken.type == Types.EOF) {
      //throw Exception('Error parsing input.\nExpected token to be EOF but got {$currentToken}');
      print('RESULT: $result');
    } else {
      //recursion
      expr(leftValue: result);
    }
  }
}
