import "package:flutter/material.dart";

class MyButton extends StatelessWidget {
  const MyButton({super.key});

  @override
  Widget build(BuildContext context) {
    // Tra ve Scaffold - widget cung cap bo cuc Material Design co ban
    // Man hinh
    return Scaffold(
      // Tiêu đề của ứng dụng
      appBar: AppBar(
        // Tieu de
        title: Text("project_02"),
        // Mau nen
        backgroundColor: Colors.yellow,
        // Do nang/ do bong cua AppBar
        elevation: 4,
        actions: [
          IconButton(
            onPressed: () {
              print("b1");
            },
            icon: Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {
              print("b2");
            },
            icon: Icon(Icons.abc),
          ),
          IconButton(
            onPressed: () {
              print("b3");
            },
            icon: Icon(Icons.more_vert),
          ),
        ],
      ),

      body: Center(
        child: Column(
          children: [
            SizedBox(height: 50,),
            ElevatedButton(onPressed: (){
              print("Click me!");
              },
                child: Text("Click me!", style: TextStyle(fontSize: 24)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  foregroundColor: Colors.white,
                ),
            ),
            SizedBox(height: 20),
            TextButton(
                onPressed: (){},
                child: Text("Button 2", style: TextStyle(fontSize: 24))
            ),
            SizedBox(height: 20),
            OutlinedButton(
                onPressed: (){},
                child: Text("Button 3", style: TextStyle(fontSize: 24))
            ),
            SizedBox(height: 20),
            IconButton(
                onPressed: (){},
                icon: Icon(Icons.favorite)
            ),
            SizedBox(height: 20),
            FloatingActionButton(onPressed: (){}, child: Icon(Icons.add)),

            SizedBox(height: 20),
            ElevatedButton(onPressed: (){
              print("Click me!");
            },
              child: Text("Click me!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 50,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
                onPressed: (){},
                icon: Icon(Icons.favorite),
                label: Text("Yêu thích")
            ),
            SizedBox(height: 20),
            TextButton.icon(
                onPressed: (){},
                icon: Icon(Icons.favorite),
                label: Text("Yêu thích")
            ),
            SizedBox(height: 20),
            InkWell(
              onTap: (){
                print("Inkwell được nhấn!");
              },
              splashColor: Colors.brown.withOpacity(0.5),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black45),
                ),
                child: Text("Button tùy chỉnh với Inkwell"),
              )
            )
          ],
        )
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print("pressed");
        },
        child: const Icon(Icons.add_ic_call),
      ),

      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Trang chủ"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Tìm kiếm"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Cá nhân"),
        ],
      ),
    );
  }
}
