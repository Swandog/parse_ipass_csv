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
        if 'Transaction Date' in headers:
            transaction_datetime=datetime.strptime(row[headers['Transaction Date']], '%b %d, %Y %I:%M:%S %p')
        elif 'Posting Date' in headers:
            transaction_datetime=datetime.strptime(row[headers['Posting Date']], '%Y/%m/%d %H:%M:%S')
        else:
            raise ValueError("transaction_datetime")
           
        date=transaction_datetime.strftime('%m/%d/%Y')

        if 'Location' in headers:
            location=row[headers['Location']]
        elif 'Plaza' in headers:
            location=row[headers['Plaza']]
        else:
            raise ValueError("location")
        
        payee='-'.join(location.split('-')[0:2])
        category=''
        memo=location
        outflow=abs(float(row[headers['Amount']].replace('$', '')))
        inflow=''

        print(date, payee, category, memo, outflow, inflow, sep=',')

