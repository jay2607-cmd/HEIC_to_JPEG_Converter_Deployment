import 'package:flutter/material.dart';

class LicenseAndCredit extends StatefulWidget {
  const LicenseAndCredit({super.key});

  @override
  State<LicenseAndCredit> createState() => _LicenseAndCreditState();
}

class _LicenseAndCreditState extends State<LicenseAndCredit> {
  @override
  Widget build(BuildContext context) {
    return LicensePage(
      applicationName: "HEIC Converter",
    );
  }
}
