import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddTask extends StatefulWidget {
  bool update;
  String docID, name, description, date, hour;
  int importance;
  AddTask(this.update, this.docID, this.name, this.description, this.date,
      this.hour, this.importance);

  @override
  _AddTaskState createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  var size;
  var txtName = TextEditingController();
  var txtDescription = TextEditingController();
  var txtDate = TextEditingController();
  var txtHour = TextEditingController();

  bool one = true, two = false, three = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    prefill();
  }

  void prefill() {
    if (widget.update) {
      txtName.text = widget.name;
      txtDescription.text = widget.description;
      txtDate.text = widget.date;
      txtHour.text = widget.hour;
      switch (widget.importance) {
        case 1:
          one = true;
          two = false;
          three = false;
          break;
        case 2:
          one = false;
          two = true;
          three = false;
          break;
        case 3:
          one = false;
          two = false;
          three = true;
          break;
      }
    }
  }

  void createTask() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('tasks')
        .doc(widget.update ? widget.docID : null)
        .set({
      'name': txtName.text,
      'description': txtDescription.text,
      'date': txtDate.text,
      'hour': txtHour.text,
      'importance': one ? 1 : (two ? 2 : 3),
      'timestamp': DateTime.now().toString(),
    });
    Navigator.of(context).pop(true);
  }

  void deleteTask() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('tasks')
        .doc(widget.docID)
        .delete();
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        body: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 80,
                width: size.width,
                color: Colors.white,
                alignment: Alignment.center,
                child: Image(
                  image: AssetImage('assets/logo.png'),
                  width: 250,
                ),
              ),
              Expanded(
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Image(
                      image: AssetImage('assets/dashboard-bg.png'),
                      height: size.height - 80,
                      width: size.width,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      padding: EdgeInsets.only(
                          top: 40, left: 40, right: 40, bottom: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Container(
                              height: size.height * 0.8,
                              width: double.infinity,
                              padding: EdgeInsets.all(15),
                              margin: EdgeInsets.only(top: 20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.35),
                                    blurRadius: 15,
                                    spreadRadius: 5,
                                    offset: Offset(0, 0),
                                  )
                                ],
                              ),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                physics: BouncingScrollPhysics(),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          icon: Icon(
                                            Icons.arrow_back_rounded,
                                            color: Colors.black,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: Text(
                                            widget.update
                                                ? widget.name
                                                : 'New Task',
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                            color: Colors.orange,
                                            shape: BoxShape.rectangle,
                                          ),
                                          child: TextButton(
                                            child: Padding(
                                              padding: EdgeInsets.all(10),
                                              child: Text(
                                                widget.update
                                                    ? 'Update'
                                                    : 'Save',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            onPressed: () {
                                              createTask();
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.blue,
                                            width: 2,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        ),
                                        child: TextField(
                                          controller: txtName,
                                          decoration: const InputDecoration(
                                            labelText: 'Name',
                                            contentPadding:
                                                EdgeInsets.only(left: 20),
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.blue,
                                            width: 2,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        ),
                                        child: TextField(
                                          controller: txtDescription,
                                          decoration: const InputDecoration(
                                            labelText: 'Description',
                                            contentPadding:
                                                EdgeInsets.only(left: 20),
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.blue,
                                            width: 2,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        ),
                                        child: TextField(
                                          controller: txtDate,
                                          decoration: const InputDecoration(
                                            labelText: 'Date',
                                            contentPadding:
                                                EdgeInsets.only(left: 20),
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.blue,
                                            width: 2,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        ),
                                        child: TextField(
                                          controller: txtHour,
                                          decoration: const InputDecoration(
                                            labelText: 'Hour',
                                            contentPadding:
                                                EdgeInsets.only(left: 20),
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      'Importance Of Task:',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              one = true;
                                              two = false;
                                              three = false;
                                            });
                                          },
                                          child: Container(
                                            height: 40,
                                            width: 40,
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: one
                                                  ? Colors.blue[900]
                                                  : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              border: Border.all(
                                                color: Colors.blue[900]!,
                                                width: 1,
                                              ),
                                            ),
                                            child: Text(
                                              '1',
                                              style: TextStyle(
                                                color: one
                                                    ? Colors.white
                                                    : Colors.black,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              one = false;
                                              two = true;
                                              three = false;
                                            });
                                          },
                                          child: Container(
                                            height: 40,
                                            width: 40,
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: two
                                                  ? Colors.blue[900]
                                                  : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              border: Border.all(
                                                color: Colors.blue[900]!,
                                                width: 1,
                                              ),
                                            ),
                                            child: Text(
                                              '2',
                                              style: TextStyle(
                                                color: two
                                                    ? Colors.white
                                                    : Colors.black,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              one = false;
                                              two = false;
                                              three = true;
                                            });
                                          },
                                          child: Container(
                                            height: 40,
                                            width: 40,
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: three
                                                  ? Colors.blue[900]
                                                  : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              border: Border.all(
                                                color: Colors.blue[900]!,
                                                width: 1,
                                              ),
                                            ),
                                            child: Text(
                                              '3',
                                              style: TextStyle(
                                                color: three
                                                    ? Colors.white
                                                    : Colors.black,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    Visibility(
                                      visible: widget.update,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                          color: Colors.red,
                                          shape: BoxShape.rectangle,
                                        ),
                                        child: TextButton(
                                          child: Padding(
                                            padding: EdgeInsets.all(10),
                                            child: Text(
                                              'Delete Task',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          onPressed: () {
                                            deleteTask();
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 25,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
