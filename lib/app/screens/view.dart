import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share/share.dart';

import '../../services/database.dart';
import '../data/models.dart';
import 'edit.dart';

class ViewNotePage extends StatefulWidget {
  Function()? triggerRefetch;
  NotesModel? currentNote;
  ViewNotePage({Key? key, this.triggerRefetch, this.currentNote})
      : super(key: key) {
    this.triggerRefetch = triggerRefetch;
    this.currentNote = currentNote;
  }
  @override
  _ViewNotePageState createState() => _ViewNotePageState();
}

class _ViewNotePageState extends State<ViewNotePage> {
  @override
  void initState() {
    super.initState();
    showHeader();
  }

  void showHeader() async {
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        headerShouldShow = true;
      });
    });
  }

  bool headerShouldShow = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: <Widget>[
        ListView(
          physics: const BouncingScrollPhysics(),
          children: <Widget>[
            Container(
              height: 40,
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 24.0, right: 24.0, top: 40.0, bottom: 16),
              child: AnimatedOpacity(
                opacity: headerShouldShow ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeIn,
                child: Text(
                  widget.currentNote!.title!,
                  style: const TextStyle(
                    fontFamily: 'ZillaSlab',
                    fontWeight: FontWeight.w700,
                    fontSize: 36,
                  ),
                  overflow: TextOverflow.visible,
                  softWrap: true,
                ),
              ),
            ),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: headerShouldShow ? 1 : 0,
              child: Padding(
                padding: const EdgeInsets.only(left: 24),
                child: Text(
                  DateFormat.yMd().add_jm().format(widget.currentNote!.date!),
                  style: TextStyle(
                      fontWeight: FontWeight.w500, color: Colors.grey.shade500),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 24.0, top: 36, bottom: 24, right: 24),
              child: Text(
                widget.currentNote!.content!,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            )
          ],
        ),
        ClipRect(
          child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                height: 80,
                color: Theme.of(context).canvasColor.withOpacity(0.3),
                child: SafeArea(
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: handleBack,
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(widget.currentNote!.isImportant!
                            ? Icons.flag
                            : Icons.outlined_flag),
                        onPressed: () {
                          markImportantAsDirty();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: handleDelete,
                      ),
                      IconButton(
                        icon: const Icon(Icons.share_outlined),
                        onPressed: handleShare,
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: handleEdit,
                      ),
                    ],
                  ),
                ),
              )),
        )
      ],
    ));
  }

  void handleSave() async {
    await NotesDatabaseService.db.updateNoteInDB(widget.currentNote!);
    widget.triggerRefetch!();
  }

  void markImportantAsDirty() {
    setState(() {
      widget.currentNote!.isImportant = !widget.currentNote!.isImportant!;
    });
    handleSave();
  }

  void handleEdit() {
    Navigator.pop(context);
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => EditNotePage(
          existingNote: widget.currentNote,
          triggerRefetch: widget.triggerRefetch,
        ),
      ),
    );
  }

  void handleShare() {
    Share.share(
      '${widget.currentNote!.title!.trim()}\n(On: ${widget.currentNote!.date!.toIso8601String().substring(0, 10)})\n\n${widget.currentNote!.content}',
    );
  }

  void handleBack() {
    Navigator.pop(context);
  }

  void handleDelete() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            title: const Text('Delete Note'),
            content: const Text('This note will be deleted permanently'),
            actions: <Widget>[
              FlatButton(
                child: Text('DELETE',
                    style: TextStyle(
                        color: Colors.red.shade300,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1)),
                onPressed: () async {
                  await NotesDatabaseService.db
                      .deleteNoteInDB(widget.currentNote!);
                  widget.triggerRefetch!();
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text('CANCEL',
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1)),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }
}
