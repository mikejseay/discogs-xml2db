#!/usr/bin/env python
import bz2
import sys
import os
import pathlib

from psycopg2 import sql
from glob import glob

from dbconfig import connect_db, Config

# since we run this as a script, we need to add the parent folder
# so we can import discogsxml2db from it
parent_path = str(pathlib.Path(__file__).absolute().parent.parent)
sys.path.insert(1, parent_path)
from discogsxml2db.exporter import csv_headers  # noqa


def load_csv(filename, db):
    print("Importing data from {}".format(filename))
    base, fname = os.path.split(filename)
    table, ext = fname.split('.', 1)
    if ext.startswith('csv'):
        q = sql.SQL("COPY {} ({}) FROM STDIN WITH CSV HEADER").format(
                sql.Identifier(table),
                sql.SQL(', ').join(map(sql.Identifier, csv_headers[table])))

    if ext == 'csv':
        fp = open(filename, encoding='utf-8')
    elif ext == 'csv.bz2':
        fp = bz2.BZ2File(filename)

    cursor = db.cursor()
    cursor.copy_expert(q, fp)
    db.commit()


root = os.path.realpath(os.path.dirname(__file__))
config = Config(os.path.join(root, 'postgresql.conf'))
db = connect_db(config)

filenames = glob(sys.argv[1])

for filename in filenames:
    load_csv(os.path.abspath(filename), db)
