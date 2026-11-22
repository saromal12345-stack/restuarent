# Spice Route - Restaurant Management System

A restaurant management system built on a MySQL database, with a Python (Flask) backend and web pages for staff and customers.

## Features

- Menu: add dishes and prices from a web page
- Orders: several dishes in one order, with a waiter and table number
- Kitchen view: pending orders, with a button to mark them as served
- Billing: a printable bill with 5% tax
- Sales report: sales per day, month and year, top dishes, and sales per waiter
- QR menu: customers scan a QR code, enter their name, phone number and table number, and order from their phone (these orders show "Online" as the waiter)
- Price history: a trigger records every price change
- Prices are saved on each order line, so old bills never change when the menu price changes
- Staff pages work only from the computer running the app, and only the QR menu is open to other devices

## Database

Tables: `menu`, `customers`, `orders`, `order_items`, `waiters`, `price_log`

SQL concepts used: primary and foreign keys, auto-increment, CHECK constraints, JOINs, GROUP BY, views, an index, a stored procedure, a trigger and transactions.

## Tools

MySQL, MySQL Workbench, Python, Flask, HTML, CSS, JavaScript, VS Code, Git and GitHub, diagrams.net

## How to run

1. Create the database and tables in MySQL.
2. Copy `config.example.py` to `config.py` and put your own MySQL password in it. Never upload `config.py`.
3. Install the packages: `pip install flask mysql-connector-python`
4. Start the app: `python app.py`
5. Open `http://127.0.0.1:5000/orders` on the same computer.

## Power BI dashboard

`esay_july.pbix` is a separate Power BI restaurant sales dashboard. Open it in Power BI Desktop (free from Microsoft).

## About

Built by Aromal S as a college SQL project. All data is sample data.