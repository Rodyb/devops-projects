from flask import Flask, request, render_template
import psycopg2
import os  # Import 'os' to use environment variables

app = Flask(__name__)
# Default version for development

CURRENT_MAJOR_RELEASE_VERSION = "9"

APP_VERSION = "0.0.1-dev"
is_release = os.getenv("RELEASE_BUILD", "false").lower() == "true"

if is_release:
    APP_VERSION = f"9.0.0"

# Database connection settings
DB_CONFIG = {
    "host": os.getenv("DB_HOST", "localhost"),
    "database": os.getenv("DB_NAME", "exampledb"),
    "user": os.getenv("DB_USER", "exampleuser"),
    "password": os.getenv("DB_PASSWORD", "examplepass")
}

# Helper function to connect to the database
def get_db_connection():
    try:
        connection = psycopg2.connect(**DB_CONFIG)
        return connection
    except Exception as e:
        print(f"Database connection failed: {e}")
        return None

# Function to initialize the database (create the table if it doesn't exist)
def init_db():
    connection = get_db_connection()
    if connection:
        try:
            cursor = connection.cursor()
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS employees (
                    id SERIAL PRIMARY KEY,
                    name VARCHAR(100),
                    department VARCHAR(50),
                    salary NUMERIC
                )
            """)
            connection.commit()
            print("Table 'employees' initialized successfully.")
        except Exception as e:
            print(f"Error initializing database: {e}")
        finally:
            cursor.close()
            connection.close()
    else:
        print("Could not connect to the database to initialize it.")

@app.route('/')
def home():
    return render_template('index.html', version=APP_VERSION)  # Renders 'templates/index.html'

@app.route('/employees')
def view_employees():
    connection = get_db_connection()
    if connection:
        cursor = connection.cursor()
        try:
            cursor.execute('SELECT * FROM employees')
            employees = cursor.fetchall()
            return render_template('employees.html', employees=employees)
        except Exception as e:
            return f"Error fetching employees: {e}"
        finally:
            cursor.close()
            connection.close()
    else:
        return "Error connecting to the database."

@app.route('/add_employee', methods=['GET', 'POST'])
def add_employee():
    if request.method == 'POST':
        name = request.form['name']
        department = request.form['department']
        salary = request.form['salary']

        connection = get_db_connection()
        if connection:
            try:
                cursor = connection.cursor()
                cursor.execute(
                    'INSERT INTO employees (name, department, salary) VALUES (%s, %s, %s)',
                    (name, department, salary)
                )
                connection.commit()
                return "Employee added successfully! <a href='/employees'>View Employees</a>"
            except Exception as e:
                return f"Error adding employee: {e}"
            finally:
                cursor.close()
                connection.close()
        else:
            return "Error connecting to the database."

    return render_template('add_employee.html')  # Renders 'templates/add_employee.html'

if __name__ == '__main__':
    # Initialize the database before starting the app
    init_db()
    app.run(host='0.0.0.0', port=5000, debug=True)
