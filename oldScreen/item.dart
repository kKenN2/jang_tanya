import 'package:flutter/material.dart';

class Item extends StatefulWidget {
  const Item({super.key});

  @override
  State<Item> createState() => _ItemState();
}

class _ItemState extends State<Item> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("1",style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold, fontFamily:'SoulsideBetrayed'),),
          const SizedBox(height: 20,),
          OutlinedButton(
            onPressed: (){},
            child: const Text("+", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, fontFamily:'SoulsideBetrayed'))
          ),
          const SizedBox(height: 20,),
          OutlinedButton(
            onPressed: (){},
            child: const Text("-", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, fontFamily:'SoulsideBetrayed'))
          )
        ],
      ),
    );
  }
}
