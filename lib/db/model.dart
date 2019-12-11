import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sqfentity/sqfentity.dart';
import 'package:sqfentity_gen/sqfentity_gen.dart';

part 'model.g.dart';

const booksTable = SqfEntityTable(
  tableName: 'books',
  primaryKeyName: 'id',
  primaryKeyType: PrimaryKeyType.integer_unique,
  useSoftDeleting: false,
  modelName: 'BookModel',
  fields: [
    SqfEntityField('name', DbType.text),
    SqfEntityField('chapters', DbType.integer),
  ],
);

const versesTable = SqfEntityTable(
  tableName: 'verses',
  primaryKeyName: 'id',
  primaryKeyType: PrimaryKeyType.integer_auto_incremental,
  useSoftDeleting: false,
  modelName: 'VerseModel',
  fields: [
    SqfEntityFieldRelationship(
      parentTable: booksTable,
      deleteRule: DeleteRule.CASCADE,
      fieldName: 'book',
    ),
    SqfEntityField('chapter', DbType.integer),
    SqfEntityField('verse', DbType.integer),
    SqfEntityField('text', DbType.text),
  ],
);

const gamesTable = SqfEntityTable(
  tableName: 'games',
  primaryKeyType: PrimaryKeyType.integer_auto_incremental,
  primaryKeyName: 'id',
  useSoftDeleting: true,
  modelName: 'GameModel',
  fields: [
    SqfEntityField('name', DbType.text),
    SqfEntityField('startBook', DbType.integer),
    SqfEntityField('startChapter', DbType.integer),
    SqfEntityField('startVerse', DbType.integer),
    SqfEntityField('endBook', DbType.integer),
    SqfEntityField('endChapter', DbType.integer),
    SqfEntityField('endVerse', DbType.integer),
    SqfEntityField('nextBook', DbType.integer),
    SqfEntityField('nextChapter', DbType.integer),
    SqfEntityField('nextVerse', DbType.integer),
    SqfEntityField('money', DbType.integer),
    SqfEntityField('bonuses', DbType.text),
    SqfEntityField('versesCount', DbType.text),
    SqfEntityField('resolvedVersesCount', DbType.text),
  ],
);

@SqfEntityBuilder(model)
const model = SqfEntityModel(
  modelName: 'BibleGameModel',
  databaseName: 'bible_game.db',
  databaseTables: [booksTable, versesTable, gamesTable],
  sequences: [SqfEntitySequence(sequenceName: 'identity')],
  bundledDatabasePath: null,
);
