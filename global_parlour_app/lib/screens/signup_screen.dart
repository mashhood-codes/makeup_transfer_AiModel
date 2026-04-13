import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../routes/app_routes.dart';

Map<String,String> dummyUsers = {};

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  bool isLoading=false;

  void signUp(){
    final email=emailController.text.trim();
    final password=passwordController.text.trim();
    final confirm=confirmController.text.trim();

    if(email.isEmpty||password.isEmpty||confirm.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All fields required')));
      return;
    }
    if(password!=confirm){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }
    if(dummyUsers.containsKey(email)){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User already exists')));
      return;
    }
    setState(()=>isLoading=true);
    Future.delayed(const Duration(seconds: 1), (){
      if (!mounted) return;
      dummyUsers[email]=password;
      setState(()=>isLoading=false);
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              const SizedBox(height:50),
              const Text('Sign Up', style: TextStyle(fontSize:28,fontWeight:FontWeight.bold)),
              const SizedBox(height:30),
              CustomTextField(controller: emailController,hintText:'Email',icon: Icons.email),
              const SizedBox(height:15),
              CustomTextField(controller: passwordController,hintText:'Password',icon: Icons.lock,obscureText:true),
              const SizedBox(height:15),
              CustomTextField(controller: confirmController,hintText:'Confirm Password',icon: Icons.lock,obscureText:true),
              const SizedBox(height:30),
              isLoading?const Center(child:CircularProgressIndicator()):CustomButton(text:'Sign Up',onPressed:signUp),
              const SizedBox(height:20),
              TextButton(onPressed: ()=>Navigator.pushReplacementNamed(context, AppRoutes.login), child: const Text('Already have an account? Login')),
            ],
          ),
        ),
      ),
    );
  }
}