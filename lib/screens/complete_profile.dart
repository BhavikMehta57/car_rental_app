import 'package:car_rental_app/metamask.dart';
import 'package:car_rental_app/screens/owner_history.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:car_rental_app/models/user.dart';
import 'package:car_rental_app/screens/home_page.dart';
import 'package:car_rental_app/services/firebase_services.dart';
import 'package:car_rental_app/services/validation_services.dart';
import 'package:car_rental_app/widgets/widgets.dart';
import 'package:provider/provider.dart';

class CompleteProfile extends StatefulWidget {
  @override
  _CompleteProfileState createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfile> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _nameController = TextEditingController();
  TextEditingController _licenseController = TextEditingController();
  TextEditingController _ageController = TextEditingController();
  TextEditingController _bloodController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  // String _imageUrl;

  AppUser user = AppUser();
  String text = "";
  String ownAddress="";

  FirebaseFunctions firebaseFunctions = FirebaseFunctions();

  void initAppUser() {
    user.name = _nameController.text;
    user.age = _ageController.text;
    user.licenseNumber = _licenseController.text;
    user.bloodGroup = _bloodController.text;
    user.emailID = emailController.text;
    // user.dpURL = _imageUrl;
    user.phoneNumber = FirebaseAuth.instance.currentUser.phoneNumber;
    user.uuid = FirebaseAuth.instance.currentUser.uid;
    user.hasCompleteProfile = true;
    user.ownAddress = ownAddress;
  }

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text("Complete your Profile"),
      ),
      body: Builder(
        builder: (context) {
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // GestureDetector(
                    //   onTap: () async {
                    //     String image = await Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder: (context) {
                    //           return ImageSelectAndCrop();
                    //         },
                    //       ),
                    //     ) as String;
                    //
                    //     setState(() {
                    //       _imageUrl = image;
                    //     });
                    //   },
                    //   child: Container(
                    //     width: 0.4 * deviceSize.width,
                    //     height: 0.4 * deviceSize.width,
                    //     child: Center(
                    //       child: (_imageUrl != null)
                    //           ? CachedNetworkImage(
                    //               imageUrl: _imageUrl,
                    //               imageBuilder: (context, imageProvider) =>
                    //                   CircleAvatar(
                    //                 backgroundImage: imageProvider,
                    //                 radius: 0.2 * deviceSize.width,
                    //               ),
                    //               progressIndicatorBuilder:
                    //                   (context, url, downloadProgress) =>
                    //                       CircularProgressIndicator(
                    //                           value: downloadProgress.progress),
                    //               errorWidget: (context, url, error) => Icon(
                    //                 Icons.error,
                    //                 size: 40.0,
                    //               ),
                    //             )
                    //           : CircleAvatar(
                    //               radius: 0.2 * deviceSize.width,
                    //               child: Icon(
                    //                 Icons.person,
                    //                 size: 40.0,
                    //               ),
                    //             ),
                    //     ),
                    //   ),
                    // ),
                    // CustomBackButton(
                    //   pageHeader: 'Complete your profile',
                    // ),

                    SizedBox(
                      height: 20,
                    ),
                    InputFormField(
                      fieldName: 'Name',
                      obscure: false,
                      validator: ValidationService().nameValidator,
                      controller: _nameController,
                    ),
                    SizedBox(
                      height: 0.03 * deviceSize.height,
                    ),
                    InputFormField(
                      fieldName: 'Age',
                      obscure: false,
                      validator: ValidationService().ageValidator,
                      controller: _ageController,
                    ),
                    SizedBox(
                      height: 0.03 * deviceSize.height,
                    ),
                    InputFormField(
                      fieldName: 'Blood Group',
                      obscure: false,
                      validator: ValidationService().bloodValidator,
                      controller: _bloodController,
                    ),
                    SizedBox(
                      height: 0.03 * deviceSize.height,
                    ),
                    InputFormField(
                      fieldName: 'Email ID',
                      obscure: false,
                      validator: ValidationService().emailValidator,
                      controller: emailController,
                    ),
                    SizedBox(
                      height: 0.03 * deviceSize.height,
                    ),
                    InputFormField(
                      fieldName: 'License Number',
                      obscure: false,
                      validator: ValidationService().licenseValidator,
                      controller: _licenseController,
                    ),
                    SizedBox(
                      height: 0.05 * deviceSize.height,
                    ),
                    ChangeNotifierProvider(
                      create: (context) => MetaMaskProvider()..init(),
                      builder: (context, child) {
                        return Center(
                          child: Consumer<MetaMaskProvider>(
                            builder: (context, provider, child) {
                              if (provider.isConnected && provider.isInOperatingChain) {
                                text = 'Connected';
                                ownAddress = provider.currentAddress;
                                return Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: Column(
                                    children: [
                                      SpecificationWidget(
                                        text: provider.currentAddress,
                                        helpText: "Your Account Address",
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          // if (_formKey.currentState.validate() &&
                                          //     _imageUrl != null) {
                                          //   ///Tell the user that process has started
                                          //   Scaffold.of(context).showSnackBar(
                                          //       SnackBar(content: Text('Processing')));
                                          //
                                          //   ///Testing url
                                          //   print(_imageUrl);
                                          //
                                          //   ///Initialize User after successful validation of fields
                                          //   initAppUser();
                                          //
                                          //   ///Make the call to upload user data
                                          //   String isComplete = await firebaseFunctions
                                          //       .uploadUserData(user.toMap());
                                          //
                                          //   ///Check if it was uploaded successfully or else show the error
                                          //   if (isComplete == 'true') {
                                          //     Navigator.push(
                                          //       context,
                                          //       MaterialPageRoute(
                                          //         builder: (context) {
                                          //           return HomePage();
                                          //         },
                                          //       ),
                                          //     );
                                          //   } else {
                                          //     Scaffold.of(context).showSnackBar(
                                          //         SnackBar(content: Text(isComplete)));
                                          //   }
                                          // }
                                          if(_formKey.currentState.validate()){
                                            ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Processing')));
                                            initAppUser();
                                            String isComplete = await firebaseFunctions
                                                .uploadUserData(user.toMap());
                                            if (isComplete == 'true') {
                                              await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) {
                                                    return HomePage();
                                                  },
                                                ),
                                              );
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text(isComplete)));
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) {
                                                    return CompleteProfile();
                                                  },
                                                ),
                                              );
                                            }}
                                        },
                                        child: CustomButton(
                                          text: 'Save',
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              } else if (provider.isConnected && !provider.isInOperatingChain) {
                                text = 'Wrong chain. Please connect to ${MetaMaskProvider.operatingChain}';
                              } else if (provider.isEnabled) {
                                return Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      context.read<MetaMaskProvider>().connect();
                                    },
                                    child: CustomButton(
                                      text: 'Connect to Metamask',
                                    ),
                                  ),
                                );
                              } else {
                                text = 'Please use a Web3 supported browser.';
                              }
                              return Container(
                                child: Text(
                                  text,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.headline5,
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                    // GestureDetector(
                    //   onTap: () async {
                    //     // if (_formKey.currentState.validate() &&
                    //     //     _imageUrl != null) {
                    //     //   ///Tell the user that process has started
                    //     //   Scaffold.of(context).showSnackBar(
                    //     //       SnackBar(content: Text('Processing')));
                    //     //
                    //     //   ///Testing url
                    //     //   print(_imageUrl);
                    //     //
                    //     //   ///Initialize User after successful validation of fields
                    //     //   initAppUser();
                    //     //
                    //     //   ///Make the call to upload user data
                    //     //   String isComplete = await firebaseFunctions
                    //     //       .uploadUserData(user.toMap());
                    //     //
                    //     //   ///Check if it was uploaded successfully or else show the error
                    //     //   if (isComplete == 'true') {
                    //     //     Navigator.push(
                    //     //       context,
                    //     //       MaterialPageRoute(
                    //     //         builder: (context) {
                    //     //           return HomePage();
                    //     //         },
                    //     //       ),
                    //     //     );
                    //     //   } else {
                    //     //     Scaffold.of(context).showSnackBar(
                    //     //         SnackBar(content: Text(isComplete)));
                    //     //   }
                    //     // }
                    //     if(_formKey.currentState.validate()){
                    //     ScaffoldMessenger.of(context).showSnackBar(
                    //         SnackBar(content: Text('Processing')));
                    //     initAppUser();
                    //     String isComplete = await firebaseFunctions
                    //         .uploadUserData(user.toMap());
                    //     if (isComplete == 'true') {
                    //       await Navigator.push(
                    //         context,
                    //         MaterialPageRoute(
                    //           builder: (context) {
                    //             return HomePage();
                    //           },
                    //         ),
                    //       );
                    //     } else {
                    //       ScaffoldMessenger.of(context).showSnackBar(
                    //           SnackBar(content: Text(isComplete)));
                    //       Navigator.push(
                    //         context,
                    //         MaterialPageRoute(
                    //           builder: (context) {
                    //             return CompleteProfile();
                    //           },
                    //         ),
                    //       );
                    //     }}
                    //   },
                    //   child: CustomButton(
                    //     text: 'Save',
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
