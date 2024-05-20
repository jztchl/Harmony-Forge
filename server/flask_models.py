from flask_sqlalchemy import SQLAlchemy
from werkzeug.security import generate_password_hash, check_password_hash
from datetime import datetime



db = SQLAlchemy()

class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name= db.Column(db.String(50),nullable=False)
    username = db.Column(db.String(50), unique=True, nullable=False)
    password_hash = db.Column(db.String(100), nullable=False)
    is_admin = db.Column(db.Boolean, default=False)
    approval = db.Column(db.String(50), nullable=True)
    otp = db.Column(db.String(16)) 

    def __init__(self,name, username, password,approval):
        self.name= name
        self.username = username
        self.password_hash = generate_password_hash(password)
        self.approval = approval

    

    def check_password(self, password):
        return check_password_hash(self.password_hash, password)

class Feedback(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    message = db.Column(db.Text, nullable=False)
    username = db.Column(db.String(50), nullable=False)
    timestamp = db.Column(db.DateTime, default=datetime.now)
    read = db.Column(db.Boolean, default=False)

    def __init__(self, message, username):
        self.message = message
        self.username = username