import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../helpers/cloud_firestore_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GlobalKey<FormState> insertFormKey = GlobalKey();
  GlobalKey<FormState> updateFormKey = GlobalKey();

  TextEditingController titleController = TextEditingController();
  TextEditingController updatedTitleController = TextEditingController();
  // TextEditingController dateController = TextEditingController();
  // TextEditingController updateDateController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController updatedDescriptionController = TextEditingController();

  String? title;
  //String? date;
  String? description;
  String? updatedTitle;
  // String? updateDate;
  String? updatedDescription;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text(
          "📚 Note-Keeper 📚",
          style: TextStyle(fontSize: 25),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addRecords,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: CloudFirestoreHelper.cloudFirestoreHelper.selectRecord(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: SelectableText("${snapshot.error}"),
              );
            } else if (snapshot.hasData) {
              QuerySnapshot? data = snapshot.data;
              List<QueryDocumentSnapshot> documents = data!.docs;
              return (documents.isNotEmpty)
                  ? ListView.builder(
                      itemCount: documents.length,
                      itemBuilder: (context, i) {
                        return Container(
                          margin: const EdgeInsets.all(5),
                          child: Card(
                              color: Colors.lightGreen,
                              margin: const EdgeInsets.all(10),
                              elevation: 6,
                              child: ListTile(
                                  isThreeLine: true,
                                  leading: Text(
                                    "${i + 1} ",
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  title: Text(
                                    "${documents[i]['title']} ",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25,
                                    ),
                                  ),
                                  subtitle: Text(
                                    "${documents[i]['description']} \n",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        onPressed: () async {
                                          updateRecord(
                                            id: documents[i].id,
                                            title: documents[i]['title'],
                                            description: documents[i]
                                                ['description'],
                                            date: '',
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.indigo,
                                          size: 25,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () async {
                                          await CloudFirestoreHelper
                                              .cloudFirestoreHelper
                                              .deleteRecord(
                                            id: documents[i].id,
                                          );
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  "Successfully Task Deleted"),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                          size: 25,
                                        ),
                                      ),
                                    ],
                                  ))),
                        );
                      },
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.note_add_outlined,
                            size: 100,
                            color: Colors.orange,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "No Task Yet !",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                            ),
                          ),
                        ],
                      ),
                    );
            } else {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.teal,
                ),
              );
            }
          }),
    );
  }

  void addRecords() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Enter Note(Task)"),
          content: Form(
            key: insertFormKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: "Enter title",
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 2,
                        color: Colors.teal,
                      ),
                    ),
                    labelStyle: TextStyle(color: Colors.teal),
                    labelText: "Title",
                    border: OutlineInputBorder(),
                  ),
                  controller: titleController,
                  onSaved: (val) {
                    setState(() {
                      title = val;
                    });
                  },
                  validator: (val) =>
                      (val!.isEmpty) ? "Enter your title first" : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: "Enter description",
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 2,
                        color: Colors.teal,
                      ),
                    ),
                    labelStyle: TextStyle(color: Colors.teal),
                    labelText: "Description",
                  ),
                  controller: descriptionController,
                  onSaved: (val) {
                    setState(() {
                      description = val;
                    });
                  },
                  validator: (val) =>
                      (val!.isEmpty) ? "Enter your description first" : null,
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                if (insertFormKey.currentState!.validate()) {
                  insertFormKey.currentState!.save();

                  await CloudFirestoreHelper.cloudFirestoreHelper
                      .insertRecord(
                    title: title!,
                    description: description!,
                  )
                      .then((value) {
                    return ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Successfully Task Added"),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }).catchError(
                    (error) {
                      return ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Error: $error"),
                        ),
                      );
                    },
                  );
                }
                titleController.clear();
                descriptionController.clear();
                //dateController.clear();

                setState(() {
                  title = "";
                  description = "";
                  //date = "";
                });
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.teal,
              ),
              child: const Text("Add"),
            ),
            ElevatedButton(
              onPressed: () {
                titleController.clear();
                descriptionController.clear();
                //dateController.clear();
                setState(() {
                  title = null;
                  description = null;
                  //date = null;
                });
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.teal,
              ),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  void updateRecord({
    required String id,
    required String title,
    required String date,
    required String description,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        updatedTitleController.text = title;
        //  updateDateController.text = date;
        updatedDescriptionController.text = description;
        return AlertDialog(
          title: const Text("Update Note(Task)"),
          content: Form(
            key: updateFormKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: "Enter title",
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 2,
                        color: Colors.teal,
                      ),
                    ),
                    labelStyle: TextStyle(color: Colors.teal),
                    labelText: "Title",
                  ),
                  controller: updatedTitleController,
                  onSaved: (val) {
                    setState(() {
                      updatedTitle = val;
                    });
                  },
                  validator: (val) =>
                      (val!.isEmpty) ? "Enter your title first" : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: "Enter description",
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 2,
                        color: Colors.teal,
                      ),
                    ),
                    labelStyle: TextStyle(color: Colors.teal),
                    labelText: "Description",
                  ),
                  controller: updatedDescriptionController,
                  onSaved: (val) {
                    setState(() {
                      updatedDescription = val;
                    });
                  },
                  validator: (val) =>
                      (val!.isEmpty) ? "Enter your description first" : null,
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                if (updateFormKey.currentState!.validate()) {
                  updateFormKey.currentState!.save();

                  Map<String, dynamic> updatedData = {
                    'title': updatedTitle,
                    // 'date': updateDate,
                    'description': updatedDescription,
                  };
                  await CloudFirestoreHelper.cloudFirestoreHelper
                      .updateRecord(updatedData: updatedData, updatedId: id);

                  updatedDescriptionController.clear();
                  updatedTitleController.clear();
                  // updateDateController.clear();

                  setState(() {
                    updatedTitle = null;
                    //  updateDate = null;
                    updatedDescription = null;
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Successfully Task Updated"),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.teal,
              ),
              child: const Text("Update"),
            ),
            ElevatedButton(
              onPressed: () {
                updatedDescriptionController.clear();
                updatedTitleController.clear();
                //updateDateController.clear();
                setState(() {
                  updatedTitle = null;
                  //updateDate = null;
                  updatedDescription = null;
                });
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.teal,
              ),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }
}
