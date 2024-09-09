import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_buddy/screens/layout_screen.dart';
import '../blocs/auth_bloc/auth_bloc.dart';

class AuthFormScreen extends StatelessWidget {
  static const routeName = '/auth_form_screen';
  const AuthFormScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
        create: (BuildContext context) => AuthBloc(), child: const AuthForm());
  }
}

class AuthForm extends StatefulWidget {
  const AuthForm({super.key});

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Welcome! 👋'),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Log in'),
                Tab(text: 'Sign up'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              getAuthForm(context, "login"),
              getAuthForm(context, "signup"),
            ],
          ),
        ),
      ),
    );
  }

  Padding getAuthForm(BuildContext context, String authType) {
    final formKey = GlobalKey<FormState>();
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (BuildContext context, state) {
            switch (state.status) {
              case FormStatus.pending:
                const CircularProgressIndicator();
                break;

              case FormStatus.error:
                setState(() {});
                break;

              case FormStatus.success:
                Navigator.pushNamed(context, LayoutScreen.routeName);
                break;
              default:
            }
          },
          child: Form(
            key: formKey,
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
                const SizedBox(
                  height: 16,
                ),
                TextFormField(
                  onChanged: (value) =>
                      {context.read<AuthBloc>().add(PasswordChanged(value))},
                  obscureText: _obscureText,
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                if (context.read<AuthBloc>().state.errorMsg != null &&
                    context.read<AuthBloc>().state.status == FormStatus.error)
                  Text(context.read<AuthBloc>().state.errorMsg ?? ''),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      if (authType == "login") {
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
                  child: Text(authType == "login" ? 'Log in' : 'Sign up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PasswordFormField extends StatefulWidget {
  final Function(String) onChanged;
  final TextEditingController controller;

  PasswordFormField(
      {super.key, required this.onChanged, required this.controller});

  @override
  State<PasswordFormField> createState() => _PasswordFormFieldState();
}

class _PasswordFormFieldState extends State<PasswordFormField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: widget.onChanged,
      obscureText: _obscureText,
      controller: widget.controller,
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: 'Enter your password',
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        return null;
      },
    );
  }
}
