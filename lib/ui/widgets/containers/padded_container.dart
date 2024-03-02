import 'package:flutter/cupertino.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stosp/utils/size_config.dart';

class PaddedContainer extends ConsumerWidget {
  const PaddedContainer({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.safeBlockHorizontal * 2.5),
      child: child,
    );
  }
}
