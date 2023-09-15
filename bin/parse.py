#!/usr/bin/env python3

import csv
import sys
from datetime import datetime

with open(sys.argv[1], encoding='utf-8-sig') as csvfile:
    reader=csv.reader(csvfile)

    headers_line=next(reader)
    headers=dict()
    for i in range(len(headers_line)):
        headers[headers_line[i]]=i

    print('Date,Payee,Category,Memo,Outflow,Inflow')
    for row in reader:
        transaction_datetime=datetime.strptime(row[headers['Transaction Date']], '%b %d, %Y %I:%M:%S %p')
        date=transaction_datetime.strftime('%m/%d/%Y')

        payee='-'.join(row[headers['Location']].split('-')[0:2])
        category=''
        memo=row[headers['Location']]
        outflow=abs(float(row[headers['Amount']].replace('$', '')))
        inflow=''

        print(date, payee, category, memo, outflow, inflow, sep=',')

