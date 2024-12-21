// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl_phone_number_input/intl_phone_number_input.dart';
// import 'package:tradeshop/bloc/auth_bloc/auth_bloc.dart';
//
// class PhoneInputStd extends StatelessWidget {
//   PhoneInputStd({super.key});
//
//   final TextEditingController controller = TextEditingController();
//   // numberIsValid = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<AuthBloc, AuthState>(
//       builder: (context, state) {
//         return InternationalPhoneNumberInput(
//           onInputChanged: (PhoneNumber number) {
//             print(number.phoneNumber);
//             context.read<AuthBloc>().phoneNumber = number.phoneNumber!;
//           },
//           validator: (String? value) {
//             if (value == null) {
//               // numberIsValid = false;
//               return 'Please enter your phone number';
//             } else if (value.length == 10) {
//               // numberIsValid = true;
//               return null;
//             }
//             else {
//               // numberIsValid = false;
//               return 'Not a valid phone number';
//             }
//           },
//           onInputValidated: (bool value) {
//             print(value);
//           },
//           selectorConfig: const SelectorConfig(
//               selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
//               trailingSpace: false,
//               useBottomSheetSafeArea: true,
//               leadingPadding: 0,
//               setSelectorButtonAsPrefixIcon: true),
//           maxLength: 10,
//           ignoreBlank: false,
//           autoValidateMode: AutovalidateMode.onUserInteraction,
//           selectorTextStyle: TextStyle(color: Colors.black),
//           textStyle: TextStyle(color: Colors.black),
//
//           inputDecoration: const InputDecoration(
//             icon: Icon(Icons.call),
//             hintStyle: TextStyle(
//               fontSize: 14,
//             ),
//             hintText: 'Enter Your Phone Number',
//           ),
//
//           initialValue: PhoneNumber(isoCode: 'EG'),
//           textFieldController: controller,
//           formatInput: false,
//           keyboardType: TextInputType.phone,
//
//         );
//       },
//     );
//   }
// }
