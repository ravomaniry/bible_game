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
  modelName: 'Books',
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
  modelName: 'Verses',
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

@SqfEntityBuilder(model)
const model = SqfEntityModel(
  modelName: 'BibleGameModel',
  databaseName: 'bible_game.db',
  databaseTables: [booksTable, versesTable],
  sequences: [SqfEntitySequence(sequenceName: 'identity')],
  bundledDatabasePath: null,
);
