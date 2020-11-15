import 'dart:io';

enum Tokens {
  INT,
  ADD,
  SUB,
  MUL,
  DIV,
  EOF,
}

void main(List<String> args) {
  while (true) {
    var source = stdin.readLineSync();
    var lexer = Lexer(source);
    var interpreter = Interpreter(lexer);
    var result = interpreter.expr();
    print(result);
  }
}

class Token {
  final Tokens type;
  final dynamic value;

  Token(this.type, this.value) {
    print('$type $value');
  }

  @override
  String toString() {
    return 'Instance of Token\ntype: $type\nvalue: $value';
  }
}

class Lexer {
  /// source code as string
  final String source;
  /// position of `currentChar` in `source`
  int pos = 0;
  /// current characters at `pos`
  String currentChar;

  Lexer(this.source) {
    currentChar = source[pos];
  }

  /// Advance the `pos` pointer and set the `currentChar` variable to either a character or null at EOF.
  void advance() {
    pos++;
    currentChar = (pos > source.length - 1) ? (null) : (source[pos]);
  }

  /// Ignore all whitespace characters by increasing `pos` until EOF or `currentChar` isn't whitespace.
  void skipWhitespace() {
    while (currentChar != null && currentChar == ' ') {
      advance();
    }
  }

  /// Return a (multidigit) integer consumed from the input.
  int integer() {
    var result = ' ';
    while (currentChar != null && int.tryParse(currentChar) is int) {
      result += currentChar;
      advance();
    }
    return int.tryParse(result);
  }

  /// Return the next token to be found at current `pos` or throw an exception in case no valid token is to be found. 
  Token getNextToken() {
    while (currentChar != null) {

      if (currentChar == ' ') {
        skipWhitespace();
        continue;
      }

      if (int.tryParse(currentChar) is int) {
        return Token(Tokens.INT, integer());
      }

      if (currentChar == '+') {
        advance();
        return Token(Tokens.ADD, '+');
      }

      if (currentChar == '-') {
        advance();
        return Token(Tokens.SUB, '-');
      }

      if (currentChar == '*') {
        advance();
        return Token(Tokens.MUL, '*');
      }

      if (currentChar == '/') {
        advance();
        return Token(Tokens.DIV, '/');
      }

      throw Exception('''Error lexing input
        Current character does not match valid token
        character: $currentChar
        pos: $pos
      ''');

    }

    return Token(Tokens.EOF, null);
  }
}

class Interpreter {
  final Lexer lexer;
  Token currentToken;

  Interpreter(this.lexer) {
    currentToken = lexer.getNextToken();
  }

  /// Compare the current token type with the passed token type.
  /// If they match then 'eat' the current token and and assign the next token to the currentToken, otherwise raise an exception.
  void eat(Tokens token) {
    if (currentToken.type == token) {
      currentToken = lexer.getNextToken();
    } else {
      throw Exception('''Error parsing input
      Expected $token, got ${currentToken.type} with value ${currentToken.value}
      ''');
    }
  }

  /// Return an integer token value.
  /// 
  /// factor: INTEGER
  int factor() {
    var token = currentToken;
    eat(Tokens.INT);
    return token.value as int;
  }

  /// Arithmetic expression parser and interpreter.
  /// 
  /// expr: factor ((ADD | SUB | MUL | DIV) factor)*
  int expr() {
    var result = factor();

    while ([Tokens.ADD, Tokens.SUB, Tokens.MUL, Tokens.DIV].contains(currentToken.type)) {
      var token = currentToken;
      if (token.type == Tokens.MUL) {
        eat(Tokens.MUL);
        result *= factor();
      } else if (token.type == Tokens.DIV) {
        eat(Tokens.DIV);
        result ~/ factor(); //integer division
      } else if (token.type == Tokens.ADD) {
        eat(Tokens.ADD);
        result += factor();
      } else if (token.type == Tokens.SUB) {
        eat(Tokens.SUB);
        result -= factor();
      }
    }

    if (currentToken.type != Tokens.EOF) {
      throw Exception('''Error parsing input
        Expected EOF Token, got ${currentToken.type} with value ${currentToken.value}
      ''');
    }

    return result;
  }
}