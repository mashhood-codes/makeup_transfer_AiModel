import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../routes/app_routes.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState()=>_LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>{
  final emailController=TextEditingController();
  final passwordController=TextEditingController();
  bool isLoading=false;

  void login(){
    final email=emailController.text.trim();
    final password=passwordController.text.trim();

    if(email.isEmpty||password.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All fields required')));
      return;
    }
    if(!dummyUsers.containsKey(email)||dummyUsers[email]!=password){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid credentials')));
      return;
    }
    setState(()=>isLoading=true);
    Future.delayed(const Duration(seconds: 1), (){
      if (!mounted) return;
      setState(()=>isLoading=false);
      Navigator.pushReplacementNamed(context, AppRoutes.home);
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
              const Text('Login', style: TextStyle(fontSize:28,fontWeight:FontWeight.bold)),
              const SizedBox(height:30),
              CustomTextField(controller: emailController,hintText:'Email',icon: Icons.email),
              const SizedBox(height:15),
              CustomTextField(controller: passwordController,hintText:'Password',icon: Icons.lock,obscureText:true),
              const SizedBox(height:30),
              isLoading?const Center(child:CircularProgressIndicator()):CustomButton(text:'Login',onPressed:login),
              const SizedBox(height:15),
              TextButton(onPressed: ()=>Navigator.pushNamed(context, AppRoutes.forgotPassword), child: const Text('Forgot Password?')),
              TextButton(onPressed: ()=>Navigator.pushReplacementNamed(context, AppRoutes.signup), child: const Text('Don\'t have an account? Sign Up')),
            ],
          ),
        ),
      ),
    );
  }
}