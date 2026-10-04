import 'dart:async';


/// Demontrates how to conviently access stream data with Getters.
void main() {
  final bloc = Bloc();
  /// Manually update from stream
  //   bloc.emailController.sink.add("my new email");
  /// Listen for the email to change and print the value.
 
 /// Add type annotation to the method
 bloc.email.listen((value) {
    print(value);
  });
  
  /// Use Stream Getter
  bloc.changeEmail("My new email");
}


class Bloc {
  /// Mark private with '_'
  final _emailController = StreamController<String>();
  final passwordController = StreamController<String>();
 /// Add type annotation to the getter. 
 Function(String) get changeEmail => emailController.sink.add;
 Function(String) get changePassword => passwordController.sink.add;
  
  // get access to email address through the stream with type annotation 
  Stream<String> get email => emailController.stream;
  // get access to password through the stream with type annotation 
  Stream<String> get password => passwordController.stream;
}
