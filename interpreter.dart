import 'dart:io';

enum Types {
  Integer,
  Addition,
  EOF
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
  // integer, addition or end of file
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
    if (pos > source.length - 1) {
      return Token(Types.EOF, null);
    }

    var currentChar = source[pos];

    // if currentChar.isAnNumber: return integer token
    var currentCharAsInt = int.tryParse(currentChar);
    if (currentCharAsInt is int) {
      var token = Token(Types.Integer, currentCharAsInt);
      pos += 1;
      return token;
    }

    // if currentChar.isPlus: return addition token
    if (currentChar == '+') {
      var token = Token(Types.Addition, '+');
      pos += 1;
      return token;
    }

    // error: current char not of type addition, integer or end of file
    throw Exception('Error parsing input');
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
      throw Exception('Error parsing input');
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
    var _ = currentToken;
    eat(Types.Addition);

    var right = currentToken;
    eat(Types.Integer);

    /*
    after the above call the self.current_token is set to
    EOF token

    at this point INTEGER PLUS INTEGER sequence of tokens
    has been successfully found and the method can just
    return the result of adding two integers, thus
    effectively interpreting client input
    */

    var result = left.value + right.value;
    return result;
  }
}