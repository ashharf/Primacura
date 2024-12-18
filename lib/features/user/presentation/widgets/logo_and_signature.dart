import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../cubit/user_cubit.dart';
import '../provider/logo_and_signature_provider.dart';

class LogoAndSignature extends StatelessWidget {
  const LogoAndSignature({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        return Consumer<LogoAndSignatureProvider>(builder: (context, provider, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Logo",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: provider.pickedlogo != null
                        ? Image.file(
                            provider.pickedlogo!,
                            height: 150,
                            width: 150,
                            fit: BoxFit.cover,
                          )
                        : (state).user?.logoUrl != null
                            ? Image.network(
                                state.user!.logoUrl!,
                                height: 150,
                              )
                            : Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey),
                                ),
                                height: 150,
                                width: 150,
                                child: Text("No Logo"),
                              ),
                  ),
                  SizedBox(width: 10),
                  TextButton(
                    onPressed: provider.pickLogo,
                    child: Text("Change"),
                  )
                ],
              ),
              SizedBox(height: 20),
              Text(
                "Signature",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: provider.pickedSignature != null
                        ? Image.file(
                            provider.pickedSignature!,
                            height: 150,
                            width: 150,
                            fit: BoxFit.cover,
                          )
                        : state.user?.signatureUrl != null
                            ? Image.network(
                                state.user!.signatureUrl!,
                                height: 150,
                              )
                            : Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey),
                                ),
                                height: 150,
                                width: 150,
                                child: Text("No Signature"),
                              ),
                  ),
                  SizedBox(width: 10),
                  TextButton(
                    onPressed: provider.pickSignature,
                    child: Text("Change"),
                  )
                ],
              ),
            ],
          );
        });
      },
    );
  }
}
