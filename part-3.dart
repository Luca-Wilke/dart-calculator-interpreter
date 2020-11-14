void main(List<String> args) {
  var lexer = Lexer('1+1'); //modify
  var tokens = lexer.scan();
  var parser = Parser(tokens);
  var result = parser.parse();
  print('RESULT: $result');
}

enum Types {
  Integer,
  Addition,
  Substraction,
  EOF,
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

  void _step() {
    pos += 1;
    currentChar = (pos > source.length - 1) ? (null) : (source[pos]);
  }

  void _skipWhitespace() {
    while (currentChar != null && currentChar == ' ') {
      _step();
    }
  }

  int _integer() {
    var value = '';

    while (currentChar != null && int.tryParse(currentChar) is int) {
      value += currentChar;
      _step();
    }

    return int.tryParse(value);
  }

  Token _getNextToken() {
    _skipWhitespace();

    if (currentChar == null) return Token(Types.EOF, null);

    if (int.tryParse(currentChar) is int) {
      var value = _integer();
      return Token(Types.Integer, value);
    }

    if (currentChar == '+') {
      return Token(Types.Addition, '+');
    }

    if (currentChar == '-') {
      return Token(Types.Substraction, '-');
    }

    throw Exception('Error lexing source.\nCould not find token of any valid type.\npos: ${pos} currentChar: ${currentChar}');
  }

  List<Token> scan() {
    var tokens = <Token>[_getNextToken()];
    _step();

    while (tokens.last.type != Types.EOF) {
      tokens.add(_getNextToken());
      _step();
    }

    return tokens;
  }

  void scanmsg() {
    print('pos: ${pos} char: ${currentChar}');
  }
}

class Parser {
  final List<Token> tokens;
  int pos = 0;

  Parser(this.tokens);

  int parse() {
    var result = integer();
    step();

    while (tokens[pos].type == Types.Addition || tokens[pos].type == Types.Substraction) {
      var op = getOp();
      step();
      var number = integer();
      step();
      result = (op == '+') ? (result + number) : (result - number);
    }

    return result;
  }

  void step() {
    pos += 1;
  }

  int integer() {
    if (tokens[pos].type == Types.Integer) return tokens[pos].value;
    throw Exception('Error parsing tokens.\nExpected integer, got ${tokens[pos]}');
  }

  String getOp() {
    if (tokens[pos].type == Types.Addition) return '+';
    if (tokens[pos].type == Types.Substraction) return '-';
    throw Exception('Error parsing tokens.\nExpected operator, got ${tokens[pos]}');
  }
}