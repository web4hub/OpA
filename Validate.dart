import 'dart:html';
import 'dart:async';

void main() {
  final InputElement input = querySelector("input") as InputElement;
  final DivElement div = querySelector('#error') as DivElement;

  /// Create Stream Transformer Object
  final validateEmail =
      StreamTransformer.fromHandlers(handleData: (inputValue, sink) {
    if (inputValue.toString().contains('@')) {
      sink.add(inputValue);
    } else {
      sink.addError('Enter a valid email address');
    }
  });
  
  final validateDomain =
      StreamTransformer.fromHandlers(handleData: (inputValue, sink) {
    if (inputValue.toString().contains('.com')) {
      sink.add(inputValue);
    } else {
      sink.addError('Enter a valid email address');
    }
  });

  /// Dynamically Print User Input
  input.onInput
      .map((dynamic event) => event.target.value)
      .transform(validateEmail)
      .transform(validateDomain)
      .listen((inputValue) => div.innerHtml = '',
          onError: (err) => div.innerHtml = err);
}
