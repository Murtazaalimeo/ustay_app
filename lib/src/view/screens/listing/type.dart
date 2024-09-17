import 'package:flutter/material.dart';
import 'package:fyp/src/view/screens/listing/LocArea.dart';

class Type extends StatefulWidget {
  const Type({Key? key, required this.property}) : super(key: key);

  final String property;

  @override
  State<Type> createState() => _TypeState();
}

class _TypeState extends State<Type> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width * 1;
    final height = MediaQuery.sizeOf(context).height * 1;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepPurple,
          title: const Text(
            "Real Estate",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          bottom: const TabBar(
            isScrollable: true,
            labelPadding: EdgeInsets.symmetric(horizontal: 16.0),
            tabs: [
              Tab(
                child: ReuseAbleBoardsName(
                  boardtitle: 'Home',
                ),
              ),
              Tab(
                child: ReuseAbleBoardsName(
                  boardtitle: 'Plots',
                ),
              ),
              Tab(
                child: ReuseAbleBoardsName(
                  boardtitle: 'Commercial',
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ReUseAbleClassesColumn(
              width: width,
              height: height,
              boardTitle: 'Houses',
              property: widget.property,
              categories: const [' Home', 'Flat', 'Upper Portion', 'Lower Portion', 'Farm House', 'Room,'],
            ),
            ReUseAbleClassesColumn(
              width: width,
              height: height,
              boardTitle: 'Plots',
              property: widget.property,
              categories: const ['Residential Plot', 'Commercial Plot', 'Plot File', 'Agricultural Land', 'Industrial Land', 'Plot Foam'],
            ),
            ReUseAbleClassesColumn(
              width: width,
              height: height,
              boardTitle: 'Commercial',
              property: widget.property,
              categories: const ['Furnished Offices', 'New Offices', 'Small Offices', 'New Shops', 'Commercial Others....'],
            ),
          ],
        ),
        backgroundColor: Colors.white,
      ),
    );
  }
}

class ReuseAbleBoardsName extends StatelessWidget {
  final String boardtitle;
  const ReuseAbleBoardsName({
    Key? key,
    required this.boardtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      boardtitle,
      style: const TextStyle(color: Colors.white),
    );
  }
}

class ReUseAbleClassesColumn extends StatelessWidget {
  const ReUseAbleClassesColumn({
    Key? key,
    required this.height,
    required this.width,
    required this.boardTitle,
    required this.categories,
    required this.property,
  }) : super(key: key);

  final double width;
  final double height;
  final String boardTitle;
  final List<String> categories;
  final String property;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Column(
        children: [
          for (int i = 0; i < categories.length; i += 2)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (i < categories.length)
                  ReUseAbleClassContainer(
                    width: width / 2 - 30,
                    height: height * 0.10,
                    title: categories[i],
                    boardTitle: boardTitle,
                    property: property,
                  ),
                const SizedBox(width: 8.0),
                if (i + 1 < categories.length)
                  ReUseAbleClassContainer(
                    width: width / 2 - 30,
                    height: height * 0.10,
                    title: categories[i + 1],
                    boardTitle: boardTitle,
                    property: property,
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class ReUseAbleClassContainer extends StatelessWidget {
  final String title;
  final String boardTitle;
  final String property;
  final double height;
  final double width;

  const ReUseAbleClassContainer({
    Key? key,
    required this.title,
    required this.height,
    required this.width,
    required this.boardTitle,
    required this.property,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LocationAreaSelectionScreen(
              property: property,
              propertyType: boardTitle,
              category: title,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: width,
          height: height,
          margin: const EdgeInsets.symmetric(horizontal: 5.0),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(50.0),
            border: Border.all(color: Colors.indigo),
          ),
          child: Center(
            child: Text(
              title,
              style: const TextStyle(fontSize: 10.0, color: Colors.indigo),
            ),
          ),
        ),
      ),
    );
  }
}
