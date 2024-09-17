import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ImageButton extends StatelessWidget{
  final String btname;
  final Icon? icon;
  final Color bgcolor;
  final TextStyle? textstyle;
  final VoidCallback? callback;
  final bool loading;

  const ImageButton({super.key,
    required this.btname,
    this.icon,
    this.bgcolor = Colors.blue,
    this.textstyle,
    this.loading = false,
    this.callback});


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image:  const DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage(
                'assets/img/loginbtn.png'
            )
        )
      ),
      child: ElevatedButton(onPressed: (){
        callback!();
      }, child: loading ? CircularProgressIndicator(strokeWidth: 3, color: Colors.white,) :
      icon!=null ? Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon!,
          Container(width: 11,),
          Text(btname, style: textstyle,)

        ],
      ):
      Text(btname, style: textstyle,),
          style: ElevatedButton.styleFrom(
              backgroundColor: bgcolor,
              shadowColor: bgcolor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11),
              )

          )
      ),
    );
  }

}