import threading
import webbrowser
import time
from decimal import Decimal
from flask import Flask, jsonify, render_template, request, redirect
import mysql.connector
import config

app = Flask(__name__)


def get_connection():
    return mysql.connector.connect(
        host=config.DB_HOST,
        user=config.DB_USER,
        password=config.DB_PASSWORD,
        database=config.DB_NAME,
    )


@app.route("/")
def home():
    return "Restaurant app is running"


@app.route("/menu")
def menu():
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT item_id, item_name, price FROM menu")
    rows = cursor.fetchall()
    cursor.close()
    conn.close()
    return jsonify(rows)


@app.route("/menu-page")
def menu_page():
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT item_name, price FROM menu")
    rows = cursor.fetchall()
    cursor.close()
    conn.close()
    return render_template("menu.html", items=rows)


@app.route("/orders")
def orders_page():
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute(
        "SELECT customers_id, name FROM customers "
        "ORDER BY (name = 'Walk-in Customer') DESC, name"
    )
    customers = cursor.fetchall()
    cursor.execute(
        "SELECT waiter_id, name FROM waiters WHERE name <> 'Online' ORDER BY name"
    )
    waiters = cursor.fetchall()
    cursor.execute("SELECT item_id, item_name, price FROM menu ORDER BY item_name")
    menu_items = cursor.fetchall()
    cursor.execute("SELECT * FROM order_bills ORDER BY order_id DESC")
    bills = cursor.fetchall()
    cursor.close()
    conn.close()
    return render_template(
        "orders.html",
        customers=customers,
        waiters=waiters,
        menu=menu_items,
        bills=bills,
    )


@app.route("/place-order", methods=["POST"])
def place_order():
    customer = int(request.form["customer"])
    waiter = request.form.get("waiter") or None
    table_no = request.form.get("table_no") or None
    items = request.form.getlist("item")
    qtys = request.form.getlist("qty")

    wanted = {}
    for item, qty in zip(items, qtys):
        try:
            item_id = int(item)
            quantity = int(qty)
        except ValueError:
            continue
        if quantity < 1:
            continue
        wanted[item_id] = wanted.get(item_id, 0) + quantity

    if not wanted:
        return redirect("/orders")

    conn = get_connection()
    cursor = conn.cursor()
    try:
        cursor.execute(
            "INSERT INTO orders (customers_id, waiter_id, table_no, order_date) "
            "VALUES (%s, %s, %s, CURDATE())",
            (customer, waiter, table_no),
        )
        order_id = cursor.lastrowid
        for item_id, quantity in wanted.items():
            cursor.execute(
                """
                INSERT INTO order_items (order_id, item_id, quantity, unit_price)
                SELECT %s, %s, %s, price FROM menu WHERE item_id = %s
                """,
                (order_id, item_id, quantity, item_id),
            )
        conn.commit()
    except Exception:
        conn.rollback()
        raise
    finally:
        cursor.close()
        conn.close()
    return redirect("/orders")

@app.route("/kitchen")
def kitchen():
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute(
        """
        SELECT orders.order_id, customers.name, orders.status,
               menu.item_name, order_items.quantity
        FROM orders
        JOIN customers ON orders.customers_id = customers.customers_id
        JOIN order_items ON orders.order_id = order_items.order_id
        JOIN menu ON order_items.item_id = menu.item_id
        WHERE orders.status <> 'Served'
        ORDER BY orders.order_id
        """
    )
    rows = cursor.fetchall()
    cursor.close()
    conn.close()

    grouped = {}
    for r in rows:
        order = grouped.setdefault(
            r["order_id"],
            {
                "order_id": r["order_id"],
                "name": r["name"],
                "status": r["status"],
                "items": [],
            },
        )
        order["items"].append(
            {"item_name": r["item_name"], "quantity": r["quantity"]}
        )
    return render_template("kitchen.html", orders=list(grouped.values()))


@app.route("/mark-served", methods=["POST"])
def mark_served():
    order_id = int(request.form["order_id"])
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute(
        "UPDATE orders SET status = 'Served' WHERE order_id = %s", (order_id,)
    )
    conn.commit()
    cursor.close()
    conn.close()
    return redirect("/kitchen")

@app.route("/bill/<int:order_id>")
def bill(order_id):
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute(
        """
        SELECT orders.order_id, customers.name, orders.order_date, orders.status
        FROM orders
        JOIN customers ON orders.customers_id = customers.customers_id
        WHERE orders.order_id = %s
        """,
        (order_id,),
    )
    order = cursor.fetchone()
    if order is None:
        cursor.close()
        conn.close()
        return "Order not found", 404

    cursor.execute(
        """
        SELECT menu.item_name, order_items.quantity,
               order_items.unit_price AS price,
               order_items.quantity * order_items.unit_price AS line_total
        FROM order_items
        JOIN menu ON order_items.item_id = menu.item_id
        WHERE order_items.order_id = %s
        """,
        (order_id,),
    )
    
    items = cursor.fetchall()
    cursor.close()
    conn.close()

    subtotal = sum(i["line_total"] for i in items)
    tax = round(subtotal * Decimal("0.05"), 2)
    total = subtotal + tax
    return render_template(
        "bill.html", order=order, items=items, subtotal=subtotal, tax=tax, total=total
    )

@app.route("/customers")
def customers_page():
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute(
        "SELECT customers_id, name, phone FROM customers ORDER BY customers_id DESC"
    )
    rows = cursor.fetchall()
    cursor.close()
    conn.close()
    return render_template(
        "customers.html", customers=rows, error=request.args.get("error")
    )


@app.route("/add-customer", methods=["POST"])
def add_customer():
    name = request.form["name"].strip()
    phone = request.form["phone"].strip()
    if not name or not phone.isdigit() or len(phone) != 10:
        return redirect("/customers?error=1")

    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT 1 FROM customers WHERE phone = %s", (phone,))
    if cursor.fetchone() is not None:
        cursor.close()
        conn.close()
        return redirect("/customers?error=2")
    cursor.execute(
        "INSERT INTO customers (name, phone) VALUES (%s, %s)", (name, phone)
    )
    conn.commit()
    cursor.close()
    conn.close()
    return redirect("/customers")

@app.route("/dishes")
def dishes_page():
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT item_id, item_name, price FROM menu ORDER BY item_id DESC")
    rows = cursor.fetchall()
    cursor.close()
    conn.close()
    return render_template("dishes.html", dishes=rows, error=request.args.get("error"))


@app.route("/add-dish", methods=["POST"])
def add_dish():
    name = request.form["name"].strip()
    try:
        price = float(request.form["price"])
    except ValueError:
        return redirect("/dishes?error=1")
    if not name or price <= 0:
        return redirect("/dishes?error=1")

    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT 1 FROM menu WHERE item_name = %s", (name,))
    if cursor.fetchone() is not None:
        cursor.close()
        conn.close()
        return redirect("/dishes?error=2")
    cursor.execute(
        "INSERT INTO menu (item_name, price) VALUES (%s, %s)", (name, price)
    )
    conn.commit()
    cursor.close()
    conn.close()
    return redirect("/dishes")

def add_bars(rows):
    top = max([float(r["total"]) for r in rows], default=0)
    for r in rows:
        r["label"] = str(r["label"])
        r["total"] = round(float(r["total"]), 2)
        r["pct"] = int(r["total"] * 100 / top) if top else 0
    return rows


@app.route("/sales")
def sales():
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    amount = "SUM(order_items.quantity * order_items.unit_price)"
    source = """
        FROM orders
        JOIN order_items ON orders.order_id = order_items.order_id
    """

    cursor.execute(
        f"SELECT orders.order_date AS label, {amount} AS total {source} "
        "GROUP BY orders.order_date ORDER BY orders.order_date DESC LIMIT 14"
    )
    daily = add_bars(cursor.fetchall())

    cursor.execute(
        "SELECT CONCAT(YEAR(orders.order_date), '-', "
        "LPAD(MONTH(orders.order_date), 2, '0')) AS label, "
        f"{amount} AS total {source} GROUP BY label ORDER BY label DESC"
    )
    monthly = add_bars(cursor.fetchall())

    cursor.execute(
        f"SELECT YEAR(orders.order_date) AS label, {amount} AS total {source} "
        "GROUP BY label ORDER BY label DESC"
    )
    yearly = add_bars(cursor.fetchall())

    cursor.execute(
        f"SELECT menu.item_name AS label, {amount} AS total "
        "FROM order_items JOIN menu ON order_items.item_id = menu.item_id "
        "GROUP BY menu.item_name ORDER BY total DESC LIMIT 5"
    )
    top_dishes = add_bars(cursor.fetchall())

    cursor.execute(
        f"SELECT COALESCE(waiters.name, 'Not recorded') AS label, {amount} AS total "
        "FROM orders "
        "LEFT JOIN waiters ON orders.waiter_id = waiters.waiter_id "
        "JOIN order_items ON orders.order_id = order_items.order_id "
        "GROUP BY waiters.name ORDER BY total DESC"
    )
    by_waiter = add_bars(cursor.fetchall())

    cursor.close()
    conn.close()
    return render_template(
        "sales.html",
        daily=daily,
        monthly=monthly,
        yearly=yearly,
        top_dishes=top_dishes,
        by_waiter=by_waiter,
    )

@app.route("/waiters")
def waiters_page():
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT waiter_id, name FROM waiters ORDER BY waiter_id")
    rows = cursor.fetchall()
    cursor.close()
    conn.close()
    return render_template(
        "waiters.html", waiters=rows, error=request.args.get("error")
    )


@app.route("/add-waiter", methods=["POST"])
def add_waiter():
    name = request.form["name"].strip()
    if not name:
        return redirect("/waiters?error=1")

    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT 1 FROM waiters WHERE name = %s", (name,))
    if cursor.fetchone() is not None:
        cursor.close()
        conn.close()
        return redirect("/waiters?error=2")
    cursor.execute("INSERT INTO waiters (name) VALUES (%s)", (name,))
    conn.commit()
    cursor.close()
    conn.close()
    return redirect("/waiters")

PUBLIC_PATHS = ("/m", "/m/order", "/m/thanks")
recent_orders = {}


@app.before_request
def only_my_device():
    public = request.path in PUBLIC_PATHS or request.path.startswith("/static")
    if not public and request.remote_addr != "127.0.0.1":
        return "Not allowed", 403


@app.route("/m")
def public_menu():
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT item_id, item_name, price FROM menu ORDER BY item_name")
    rows = cursor.fetchall()
    cursor.close()
    conn.close()
    return render_template(
        "menu_public.html", items=rows, error=request.args.get("error")
    )


@app.route("/m/order", methods=["POST"])
def public_order():
    ip = request.remote_addr
    now = time.time()
    recent = [t for t in recent_orders.get(ip, []) if now - t < 600]
    if len(recent) >= 5:
        return redirect("/m?error=3")

    cust_name = request.form.get("cust_name", "").strip()
    phone = request.form.get("phone", "").strip()
    if (
        not cust_name
        or len(cust_name) > 100
        or not phone.isdigit()
        or len(phone) != 10
    ):
        return redirect("/m?error=5")

    try:
        table_no = int(request.form["table_no"])
    except (KeyError, ValueError):
        return redirect("/m?error=1")
    if table_no < 1 or table_no > 99:
        return redirect("/m?error=1")

    conn = get_connection()
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT item_id FROM menu")
        wanted = {}
        for row in cursor.fetchall():
            raw = request.form.get("qty_" + str(row["item_id"]), "0")
            try:
                qty = int(raw)
            except ValueError:
                qty = 0
            if qty > 0:
                wanted[row["item_id"]] = min(qty, 20)
        if not wanted:
            return redirect("/m?error=2")

        cursor.execute("SELECT waiter_id FROM waiters WHERE name = 'Online' LIMIT 1")
        online = cursor.fetchone()
        if online is None:
            return redirect("/m?error=4")

        cursor.execute(
            "SELECT customers_id FROM customers WHERE phone = %s LIMIT 1", (phone,)
        )
        customer = cursor.fetchone()
        if customer is None:
            cursor.execute(
                "INSERT INTO customers (name, phone) VALUES (%s, %s)",
                (cust_name, phone),
            )
            customer_id = cursor.lastrowid
        else:
            customer_id = customer["customers_id"]

        cursor.execute(
            "INSERT INTO orders (customers_id, waiter_id, table_no, order_date) "
            "VALUES (%s, %s, %s, CURDATE())",
            (customer_id, online["waiter_id"], table_no),
        )
        order_id = cursor.lastrowid
        for item_id, qty in wanted.items():
            cursor.execute(
                """
                INSERT INTO order_items (order_id, item_id, quantity, unit_price)
                SELECT %s, %s, %s, price FROM menu WHERE item_id = %s
                """,
                (order_id, item_id, qty, item_id),
            )
        conn.commit()
    except Exception:
        conn.rollback()
        raise
    finally:
        conn.close()

    recent.append(now)
    recent_orders[ip] = recent
    return redirect("/m/thanks?order=" + str(order_id) + "&table=" + str(table_no))

@app.route("/m/thanks")
def public_thanks():
    try:
        order_id = int(request.args.get("order", "0"))
        table_no = int(request.args.get("table", "0"))
    except ValueError:
        return redirect("/m")
    return render_template("thanks.html", order_id=order_id, table_no=table_no)

@app.route("/api/menu", methods=["GET"])
def api_menu():
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT item_id, item_name, price FROM menu")
    rows = cursor.fetchall()
    cursor.close()
    conn.close()
    for r in rows:
        r["price"] = float(r["price"])
    return jsonify(rows)


@app.route("/api/menu/<int:item_id>", methods=["PUT"])
def api_update_price(item_id):
    data = request.get_json(silent=True) or {}
    try:
        price = float(data["price"])
    except (KeyError, ValueError, TypeError):
        return jsonify({"error": "price is required and must be a number"}), 400
    if price <= 0:
        return jsonify({"error": "price must be above 0"}), 400

    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT 1 FROM menu WHERE item_id = %s", (item_id,))
    if cursor.fetchone() is None:
        cursor.close()
        conn.close()
        return jsonify({"error": "dish not found"}), 404
    cursor.execute("UPDATE menu SET price = %s WHERE item_id = %s", (price, item_id))
    conn.commit()
    cursor.close()
    conn.close()
    return jsonify({"message": "price updated", "item_id": item_id, "price": price})


@app.route("/api/orders/<int:order_id>", methods=["GET"])
def api_order(order_id):
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute(
        """
        SELECT orders.order_id, customers.name, orders.order_date,
               orders.status, orders.table_no
        FROM orders
        JOIN customers ON orders.customers_id = customers.customers_id
        WHERE orders.order_id = %s
        """,
        (order_id,),
    )
    order = cursor.fetchone()
    if order is None:
        cursor.close()
        conn.close()
        return jsonify({"error": "order not found"}), 404

    cursor.execute(
        """
        SELECT menu.item_name, order_items.quantity,
               order_items.unit_price AS price,
               order_items.quantity * order_items.unit_price AS line_total
        FROM order_items
        JOIN menu ON order_items.item_id = menu.item_id
        WHERE order_items.order_id = %s
        """,
        (order_id,),
    )
    items = cursor.fetchall()
    cursor.close()
    conn.close()

    for i in items:
        i["price"] = float(i["price"])
        i["line_total"] = float(i["line_total"])
    order["order_date"] = str(order["order_date"])
    order["items"] = items
    order["subtotal"] = round(sum(i["line_total"] for i in items), 2)
    return jsonify(order)


@app.route("/api/orders", methods=["POST"])
def api_create_order():
    data = request.get_json(silent=True) or {}
    try:
        customer = int(data["customer_id"])
        item = int(data["item_id"])
        qty = int(data["quantity"])
    except (KeyError, ValueError, TypeError):
        return (
            jsonify({"error": "customer_id, item_id and quantity are required numbers"}),
            400,
        )
    if qty < 1 or qty > 20:
        return jsonify({"error": "quantity must be between 1 and 20"}), 400

    conn = get_connection()
    cursor = conn.cursor()
    try:
        cursor.execute("SELECT 1 FROM customers WHERE customers_id = %s", (customer,))
        customer_exists = cursor.fetchone() is not None
        cursor.execute("SELECT 1 FROM menu WHERE item_id = %s", (item,))
        item_exists = cursor.fetchone() is not None
        if not customer_exists or not item_exists:
            return jsonify({"error": "customer or dish not found"}), 404

        cursor.execute(
            "INSERT INTO orders (customers_id, order_date) VALUES (%s, CURDATE())",
            (customer,),
        )
        order_id = cursor.lastrowid
        cursor.execute(
            """
            INSERT INTO order_items (order_id, item_id, quantity, unit_price)
            SELECT %s, %s, %s, price FROM menu WHERE item_id = %s
            """,
            (order_id, item, qty, item),
        )
        conn.commit()
    except Exception:
        conn.rollback()
        raise
    finally:
        cursor.close()
        conn.close()
    return jsonify({"message": "order placed", "order_id": order_id}), 201

if __name__ == "__main__":
    threading.Timer(1.5, lambda: webbrowser.open("http://127.0.0.1:5000/orders")).start()
    app.run(host="0.0.0.0", debug=False)