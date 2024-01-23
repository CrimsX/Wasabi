import 'package:flutter/material.dart';

void main() => runApp(
  MaterialApp(
    home: Homepage(),
    debugShowCheckedModeBanner: false,
  ),
);

class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController serverIPController = TextEditingController();
  bool isPasswordVisible = false;

  String selectedServer = 'Edmonton'; // Default server

  void switchServer() {
    // Implement server switch logic here
    setState(() {
      // Get the server IP from the input field, use the default if empty
      final newServerIP = serverIPController.text.isNotEmpty
          ? serverIPController.text
          : 'DefaultServerIP';

      // Implement your server switching logic here, for now, just print the selected server
      print('Switching server to: $newServerIP');
      // You can update the server connection here or call a function to handle the switch
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: <Widget>[
              Container(
                height: 300,
                color: Colors.lightGreen,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(top: 50),
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/Wasabi.png',
                          width: 200,
                          height: 220,
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),

              // For enter username:
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    TextFormField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        hintText: 'Enter your Username',
                        labelStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        prefixIcon: Icon(Icons.person, color: Colors.black, size: 18),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade200, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        floatingLabelStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black, width: 1.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    // for enter password:
                    SizedBox(height: 20),
                    TextFormField(
                      controller: passwordController,
                      obscureText: !isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        labelStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        prefixIcon: Icon(Icons.lock, color: Colors.black, size: 18),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              isPasswordVisible = !isPasswordVisible;
                            });
                          },
                          child: Icon(
                            isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            color: Colors.black,
                            size: 18,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade200, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        floatingLabelStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black, width: 1.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    // For server IP:
                    SizedBox(height: 20),
                    TextFormField(
                      controller: serverIPController,
                      decoration: InputDecoration(
                        labelText: 'Server IP (optional)',
                        hintText: 'Enter server IP',
                        labelStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        prefixIcon: Icon(Icons.data_usage, color: Colors.black, size: 18),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade200, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        floatingLabelStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black, width: 1.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    // For Create Account:
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () async {
                            // Navigate to CreateAccountScreen
                           // await Navigator.push(
                             // context,
                             // MaterialPageRoute(
                               // builder: (context) => (//CreateAccountScreen(),
                              //),


                            // After returning from CreateAccountScreen, you can add any desired logic here
                          },
                          child: Text(
                            'Create Account',
                            style: TextStyle(
                              color: Colors.lightGreen,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // For Log in:
                    SizedBox(height: 30),
                    MaterialButton(
                      onPressed: () {},
                      height: 45,
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      color: Colors.lightGreen,
                      child: Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 20), // Added bottom padding to the container
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


