import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth_bloc/auth_bloc.dart';

class AuthFormScreen extends StatelessWidget {
  final bool isLogin;
  const AuthFormScreen({Key? key, required this.isLogin}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
        create: (BuildContext context) => AuthBloc(),
        child: AuthForm(isLogin: isLogin));
  }
}

class AuthForm extends StatefulWidget {
  final bool isLogin;
  const AuthForm({super.key, required this.isLogin});

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: BlocListener<AuthBloc, AuthState>(
          listener: (BuildContext context, state) {
            switch (state.status) {
              case FormStatus.pending:
                const CircularProgressIndicator();
                break;

              case FormStatus.error:
                setState(() {

                });
                break;

              case FormStatus.success:
                // TODO navigate to home screen and show username
                break;
              default:
            }
          },
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  onChanged: (value) =>
                      {context.read<AuthBloc>().add(EmailChanged(value))},
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  onChanged: (value) =>
                      {context.read<AuthBloc>().add(PasswordChanged(value))},
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                if(context.read<AuthBloc>().state.errorMsg != null && context.read<AuthBloc>().state.status == FormStatus.error) Text(context.read<AuthBloc>().state.errorMsg ?? ''),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (widget.isLogin) {
                        context.read<AuthBloc>().add(SignIn());
                      } else {
                        context.read<AuthBloc>().add(SignUp());
                        if (context.read<AuthBloc>().state.status ==
                            FormStatus.success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Successfully registered'),
                            ),
                          );
                        }
                      }
                    }
                  },
                  child: Text(widget.isLogin ? 'Sign in' : 'Sign up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
