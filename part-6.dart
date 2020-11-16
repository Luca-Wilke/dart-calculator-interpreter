enum Types {
  INT,
  ADD,
  SUB,
  MUL,
  DIV,
  EOF,
  LPAREN,
  RPAREN
}

void main(List<String> args) {
  var source = '  12+1+(12+1 / (12) - 1) / (12 -1)*2'; //modify
  var interpreter = Interpreter(Lexer(source));
  print(interpreter.expr());
}

class Token {
  final Types type;
  final dynamic value;
  
  Token(this.type, this.value);
}

class Lexer {
  final String source;
  int pos = 0;
  String currentChar;

  Lexer(this.source) {
    currentChar = source[pos];
  }

  Token getNextToken() {
    
    while (currentChar != null) {

      if (currentChar == ' ') {
        skipWhitespace();
        continue;
      }

      if (int.tryParse(currentChar) is int) {
        return Token(Types.INT, scanInteger());
      }

      if (currentChar == '+') {
        step();
        return Token(Types.ADD, '+');
      }

      if (currentChar == '-') {
        step();
        return Token(Types.SUB, '-');
      }

      if (currentChar == '*') {
        step();
        return Token(Types.MUL, '*');
      }

      if (currentChar == '/') {
        step();
        return Token(Types.DIV, '/');
      }

      if (currentChar == '(') {
        step();
        return Token(Types.LPAREN, '(');
      }

      if (currentChar == ')') {
        step();
        return Token(Types.RPAREN, ')');
      }

      throw Exception('''Error lexing input
        Could not find valid token
        pos: $pos
        current char: $currentChar
      ''');

    }

    return Token(Types.EOF, null);

  }

  void step() {
    pos++;
    currentChar = (pos > source.length - 1) ? (null) : (source[pos]);
  }

  void skipWhitespace() {
    while (currentChar != null && currentChar == ' ') {
      step();
    }
  }

  int scanInteger() {
    var result = '';

    while (currentChar != null && int.tryParse(currentChar) is int) {
      result += currentChar;
      step();      
    }

    return int.tryParse(result);
  }
}

class Interpreter {
  final Lexer lexer;
  Token currentToken;

  Interpreter(this.lexer) {
    currentToken = lexer.getNextToken();
  }

  int expr() {
    var result = term();

    while ([Types.ADD, Types.SUB].contains(currentToken.type)) {
      if (currentToken.type == Types.ADD) {
        eat(Types.ADD);
        result += term();
      } else if (currentToken.type == Types.SUB) {
        eat(Types.SUB);
        result -= term();
      }
    }

    return result;
  }

  int term() {
    var result = factor();

    while ([Types.MUL, Types.DIV].contains(currentToken.type)) {
      if (currentToken.type == Types.MUL) {
        eat(Types.MUL);
        result *= factor();
      } else if (currentToken.type == Types.DIV) {
        eat(Types.DIV);
        result ~/ factor();
      }
    }

    return result;
  }

  int factor() {
    if (currentToken.type == Types.INT) {
      var token = currentToken;
      eat(Types.INT);
      return token.value as int;
    } else if (currentToken.type == Types.LPAREN) {
      eat(Types.LPAREN);
      var result = expr();
      eat(Types.RPAREN);
      return result;
    }

    throw Exception('''Error parsing input
      Expected token structure INTEGER or LPAREN, expr RPAREN
      Got token of type ${currentToken.type} with value ${currentToken.value}
    ''');
  }

  void eat(Types expectedTokenType) {
    if (currentToken.type == expectedTokenType) {
      currentToken = lexer.getNextToken();
    } else {
      throw Exception('''Error parsing input
        Expected token of type $expectedTokenType
        Got token of type ${currentToken.type} with value ${currentToken.value}
      ''');
    }
  }
}