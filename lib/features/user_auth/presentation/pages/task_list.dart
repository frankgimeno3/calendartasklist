import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TaskListPage extends StatelessWidget {
  const TaskListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Task List"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                _createData(UserModel(
                  username: "Henry",
                  age: 21,
                  adress: "London",
                ));
              },
              child: Container(
                height: 45,
                width: 100,
                decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.circular(10)),
                child: const Center(
                  child: Text(
                    "Create Data",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            StreamBuilder<List<UserModel>>(
                stream: _readData(),
                builder: (context, snapshot) {
                  if(snapshot.connectionState == ConnectionState.waiting){
                    return const Center(child: CircularProgressIndicator(),);
                  } if(snapshot.data!.isEmpty){
                    return const Center(child:Text("No Data Yet"));
                  }
                  final users = snapshot.data;
                  return Padding(padding: const EdgeInsets.all(8),
                    child: Column(
                        children: users!.map((user) {
                          return ListTile(
                            leading: GestureDetector(
                              onTap: (){
                                _deleteData(user.id!);
                              },
                              child: const Icon(Icons.delete),
                            ),
                            trailing: GestureDetector(
                              onTap: (){
                                _updateData(
                                    UserModel(
                                      id: user.id,
                                      username: "John Wick",
                                      adress: "Pakistan",)
                                );
                              },
                              child: const Icon(Icons.update),
                            ),
                            title: Text(user.username!),
                            subtitle: Text(user.adress!),
                          );
                        }).toList()
                    ),);
                }
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, "/home");
              },
              child: Container(
                height: 45,
                width: 100,
                decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.circular(10)),
                child: const Center(
                  child: Text(
                    "Go back",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Stream<List<UserModel>> _readData(){
    final userCollection = FirebaseFirestore.instance.collection("users");

    return userCollection.snapshots().map((qureySnapshot)
    => qureySnapshot.docs.map((e)
    => UserModel.fromSnapshot(e),).toList());
  }

  void _createData(UserModel userModel) {
    final userCollection = FirebaseFirestore.instance.collection("users");

    String id = userCollection.doc().id;

    final newUser = UserModel(
      username: userModel.username,
      age: userModel.age,
      adress: userModel.adress,
      id: id,
    ).toJson();

    userCollection.doc(id).set(newUser);
  }

  void _updateData(UserModel userModel) {
    final userCollection = FirebaseFirestore.instance.collection("users");

    final newData = UserModel(
      username: userModel.username,
      id: userModel.id,
      adress: userModel.adress,
      age: userModel.age,
    ).toJson();

    userCollection.doc(userModel.id).update(newData);

  }

  void _deleteData(String id) {
    final userCollection = FirebaseFirestore.instance.collection("users");

    userCollection.doc(id).delete();

  }

}

class UserModel{
  final String? username;
  final String? adress;
  final int? age;
  final String? id;

  UserModel({this.id,this.username, this.adress, this.age});


  static UserModel fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot){
    return UserModel(
      username: snapshot['username'],
      adress: snapshot['adress'],
      age: snapshot['age'],
      id: snapshot['id'],
    );
  }

  Map<String, dynamic> toJson(){
    return {
      "username": username,
      "age": age,
      "id": id,
      "adress": adress,
    };
  }
}
