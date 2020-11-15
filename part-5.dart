import 'dart:io';

enum Tokens {
  INT,
  ADD,
  SUB,
  MUL,
  DIV,
  LPAREN,
  RPAREN,
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

  Token(this.type, this.value);

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

      if (currentChar == '(') {
        advance();
        return Token(Tokens.LPAREN, '(');
      }

      if (currentChar == ')') {
        advance();
        return Token(Tokens.RPAREN, ')');
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

/// Grammar:
/// 
/// expr: term ( (ADD | SUB) term)*
/// term: factor ( (MUL | DIV) factor)*
/// factor: INTEGER | LPAREN expr RPAREN
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

  /// Arithmetic expression parser and interpreter.
  /// 
  /// expr: factor ((ADD | SUB | MUL | DIV) factor)*
  int expr() {
    var result = term();

    while ([Tokens.ADD, Tokens.SUB].contains(currentToken.type)) {
      var token = currentToken;
      if (token.type == Tokens.ADD) {
        eat(Tokens.ADD);
        result += term();
      } else if (token.type == Tokens.SUB) {
        eat(Tokens.SUB);
        result -= term();
      }
    }

    return result;
  }

  /// factor ( (MUL | DIV) factor)*
  int term() {
    var result = factor();

    while ([Tokens.MUL, Tokens.DIV].contains(currentToken.type)) {
      var token = currentToken;
      if (token.type == Tokens.MUL) {
        eat(Tokens.MUL);
        result *= factor();
      } else if (token.type == Tokens.DIV) {
        eat(Tokens.DIV);
        result ~/ factor();
      }
    }

    return result;
  }

  /// Return an integer token value.
  /// 
  /// factor: INTEGER | LPAREN expr RPAREN
  int factor() {
    var token = currentToken;

    if (token.type == Tokens.INT) {
      eat(Tokens.INT);
      return token.value as int;
    } else if (token.type == Tokens.LPAREN) {
      eat(Tokens.LPAREN);
      var result = expr();
      eat(Tokens.RPAREN);
      return result;
    }

    throw Exception('''Error parsing input
      Expected token structure {LPAREN, expr, RPAREN}
      Got token type ${currentToken.type} with value ${currentToken.value}''');
  }
}