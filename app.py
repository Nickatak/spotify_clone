from flask import Flask, render_template
from flask_sqlalchemy import SQLAlchemy

app = Flask(__name__)
app.config["SQLALCHEMY_DATABASE_URI"] = "sqlite:///spotify.db"
db = SQLAlchemy(app)


class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    password_hash = db.Column(db.String(255), nullable=False)


@app.route("/")
def index():
    return render_template("index.html")


@app.cli.command("init-db")
def init_db():
    db.create_all()
    print("Initialized the database.")


if __name__ == "__main__":
    app.run(debug=True)
