from flask import Flask, request, send_file, jsonify ,abort,render_template,make_response
import sys
import os
from io import BytesIO
from datetime import timedelta
from flask_sqlalchemy import SQLAlchemy
from music_generation import generate_music 
from convert_instrument import convert_instrument 
from data_preparation import prepare_data_and_save 
from multi_instru_music_generation import generate_multi_music
from flask_jwt_extended import JWTManager, jwt_required, create_access_token, get_jwt_identity, create_refresh_token
import shutil
from flask_models import  db,User,Feedback
from flask_mail import Mail
import random
import string
from flask import url_for
from flask_mail import Message
from werkzeug.utils import secure_filename
from werkzeug.security import generate_password_hash
from functools import wraps
import bleach
import threading
import time

app = Flask(__name__)
app.config['SECRET_KEY'] = '22e9b014f5c5a61d3c307af0b366eb28'
#db
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///users.db'
#jwtconfig
app.config['JWT_ACCESS_TOKEN_EXPIRES'] = timedelta(hours=3)
app.config['JWT_REFRESH_TOKEN_EXPIRES'] = timedelta(days=30)
#mailserver
app.config['MAIL_SERVER'] = 'smtp.gmail.com'
app.config['MAIL_PORT'] = 587
app.config['MAIL_USE_TLS'] = True
app.config['MAIL_DEFAULT_SENDER'] = 'vasujj00@gmail.com'
app.config['MAIL_USERNAME'] = 'vasujj00@gmail.com'
app.config['MAIL_PASSWORD'] = 'iyov vqdw ccci avdj'
db.init_app(app)
jwt = JWTManager(app)
mail = Mail(app)


headers = {
                'ngrok-skip-browser-warning': 'true',
                'User-Agent': 'Custom-Agent'
            }
def generate_verification_code():
        characters = string.ascii_letters + string.digits
        return ''.join(random.choice(characters) for _ in range(16))  # Random string of length 16

def generate_otp():
    return str(random.randint(10000000, 99999999))


def delete_file_after_delay(file_path):
    time.sleep(5)
    os.remove(file_path)

@app.route('/admin/login', methods=['POST'])
def admin_login():
    username = request.json.get('username')
    password = request.json.get('password')

    # Check if the user is an admin
    admin = User.query.filter_by(username=username, is_admin=True).first()

    if not admin or not admin.check_password(password):
        return jsonify({"msg": "Invalid admin credentials"}), 401

    access_token = create_access_token(identity=username)
    refresh_token = create_refresh_token(identity=username)
    return jsonify({"access_token": access_token, "refresh_token": refresh_token}), 200

def admin_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        current_user = get_jwt_identity()
        admin = User.query.filter_by(username=current_user, is_admin=True).first()
        if not admin:
            return jsonify({'message': 'Unauthorized access'}), 403
        return f(*args, **kwargs)
    return decorated_function



@app.route('/admin/dashboard', methods=['GET'])
def admin_dashboard():
    # Render admin dashboard template with necessary data
    return render_template('admin_dashboard.html')

@app.route('/admin/users/add', methods=['POST'])
@jwt_required()  # Requires JWT token for authentication
@admin_required  # Requires admin privileges
def admin_register():
    if not request.is_json:
        return jsonify({"msg": "Missing JSON in request"}), 400
    print(request.json)
    name = request.json.get('name')
    username = request.json.get('username')
    password = request.json.get('password')

    if not username or not password:
        return jsonify({"msg": "Missing username or password"}), 400

    if User.query.filter_by(username=username).first():
        return jsonify({"msg": "Username already exists"}), 400
    new_user = User(username=username, password=password, name=name, approval='approved')
    db.session.add(new_user)
    db.session.commit()

    return jsonify({"msg": "Admin user registered successfully"}), 201
# API endpoint to fetch users list, update user details, get single user details, and delete users (accessible only to admins)
@app.route('/admin/users', methods=['GET', 'PUT'])
@jwt_required()
@admin_required
def manage_users():

    if request.method == 'GET':
        # Fetch the list of users from the database
        users = User.query.all()
        # Serialize the users data into a JSON response
        user_list = []
        for user in users:
            user_data = {
                'id': user.id,
                'name': user.name,
                'username': user.username,
                'is_admin': user.is_admin,
                'approval': user.approval
            }
            user_list.append(user_data)
        return jsonify({'users': user_list})

    elif request.method == 'PUT':
        # Update user details based on the provided user ID
        data = request.get_json()
        user_id = data.get('id')
        new_name = data.get('name')
        new_username = data.get('username')
        new_is_admin = data.get('is_admin')
        new_approval = data.get('approval')

        user = db.session.get(User, user_id)
        if not user:
            return jsonify({'message': 'User not found'}), 404

        user.name = new_name if new_name else user.name
        user.username = new_username if new_username else user.username
        user.is_admin = new_is_admin if new_is_admin is not None else user.is_admin
        user.approval = new_approval if new_approval else user.approval

        db.session.commit()
        return jsonify({'message': 'User details updated successfully'})

@app.route('/admin/users/delete/<int:user_id>', methods=['DELETE'])
@jwt_required()
@admin_required
def delete_users(user_id):
    if not user_id:
        return jsonify({'message': 'User ID is required'}), 400
    user = db.session.get(User, user_id)
    if not user:
        return jsonify({'message': 'User not found'}), 404
    # Delete all feedback associated with the user
    Feedback.query.filter_by(username=user.username).delete()
    # Delete the user
    db.session.delete(user)
    db.session.commit()  
    return jsonify({'message': 'User and associated feedback deleted successfully'})



@app.route('/register', methods=['POST'])
def register():
    name = request.json.get('name')
    username = request.json.get('username')
    password = request.json.get('password')

    if not username or not password:
        return jsonify({"msg": "Missing username or password"}), 400
    username = username.lower()
    if User.query.filter_by(username=username).first():
        return jsonify({"msg": "Username already exists"}), 400
    randomcode=generate_verification_code()
    new_user = User(username=username, password=password, name=name, approval=randomcode)
    db.session.add(new_user)
    db.session.commit()
    verification_link = url_for('verify_user', username=username,verification_code=randomcode, _external=True)
    message = f"Hello {name},\n\nPlease click on the following link to verify your email:\n{verification_link}"
    msg = Message(subject="Verify Your Email", recipients=[username], body=message)
    mail.send(msg)

    return jsonify({"msg": "User registered successfully"}), 201



@app.route('/verify_user/<username>/<verification_code>', methods=['GET'])
def verify_user(username, verification_code):
    user = User.query.filter_by(username=username).first()
    if user:
        if user.approval == 'approved':
            # User is already approved
            return make_response(jsonify({'message': 'User is already approved.'}), 200, headers)
        elif user.approval == verification_code:
            # Update the user's approval status to indicate verification
            user.approval = 'approved'
            db.session.commit()
            return make_response(jsonify({'message': 'User verified successfully.'}), 200, headers)
        else:
            # Invalid verification code
            return make_response(jsonify({'message': 'Invalid verification code.'}), 400, headers)
    else:
        # User not found
        return make_response(jsonify({'message': 'User not found.'}), 404, headers)


@app.route('/login', methods=['POST'])
def login():
    username = request.json.get('username')
    password = request.json.get('password')
    

    user = User.query.filter_by(username=username).first()

    if not user or not user.check_password(password):
        return jsonify({"msg": "Invalid username or password"}), 401
    print(username,"logged in")
    if not user.approval=="approved":
        return jsonify({"msg": "please verify email"}), 400

    access_token = create_access_token(identity=username)
    refresh_token = create_refresh_token(identity={'username': username, 'name': user.name})
    return jsonify({"access_token": access_token, "refresh_token": refresh_token}), 200



@app.route('/refresh', methods=['POST'])
@jwt_required(refresh=True)
def refresh():
    current_user = get_jwt_identity()
    print(current_user,"refreshed token")
    new_access_token = create_access_token(identity=current_user)
    return jsonify({'access_token': new_access_token}), 200



# Assuming you have a route for logged-in users to change their password
@app.route('/change_password', methods=['POST'])
@jwt_required()
def change_password():
    current_user = get_jwt_identity()
    user = User.query.filter_by(username=current_user['username']).first()
    if not user:
        return jsonify({'error': 'User not found'}), 404

    old_password = request.json.get('old_password')
    new_password = request.json.get('new_password')

    if not old_password or not new_password:
        return jsonify({'error': 'Missing old or new password'}), 400
    if  not user.check_password(old_password):
        return jsonify({'error': 'Invalid old password'}), 400

    # Hash the new password before saving
    user.password_hash = generate_password_hash(new_password)
    db.session.commit()

    return jsonify({'message': 'Password changed successfully'}), 200

@app.route('/forgot_password', methods=['POST'])
def forgot_password():
    username = request.json.get('username')

    if not username:
        return jsonify({'error': 'Email is required'}), 400

    user = User.query.filter_by(username=username).first()
    if not user:
        return jsonify({'error': 'User not found'}), 404

    # Generate an 8-digit numerical OTP
    otp = generate_otp()

    # Store the OTP in the database (assuming you have an 'otp' column)
    user.otp = otp
    db.session.commit()

    # Send the OTP via email
    message = f"Your OTP for password reset: {otp}"
    msg = Message(subject="Password Reset OTP", recipients=[username], body=message)
    mail.send(msg)

    return jsonify({'message': 'OTP sent to your email'}), 200


@app.route('/reset_password', methods=['POST'])
def reset_password():
    username = request.json.get('username')
    otp = request.json.get('otp')
    new_password = request.json.get('new_password')

    if not username or not otp or not new_password:
        return jsonify({'error': 'Email, OTP, and new password are required'}), 400

    user = User.query.filter_by(username=username, otp=otp).first()
    if not user:
        return jsonify({'error': 'Invalid OTP or email'}), 400
    
    user.password_hash = generate_password_hash(new_password)
    user.otp = None  # Clear the OTP after password reset
    
    db.session.commit()
    return jsonify({'message': 'Password reset successfully'}), 200

@app.route('/protected', methods=['GET'])
@jwt_required()
def protected():
    current_user = get_jwt_identity()
    return jsonify(logged_in_as=current_user), 200


def train_model(model_folder):
    model_training_script = "model_training.py"
    os.system(f"python {model_training_script} {model_folder}")

@app.route('/train_model', methods=['POST'])
@jwt_required()
@admin_required
def train_model_endpoint():
    # Check if the request contains the 'modelName' field in the form data
    if 'modelName' not in request.form:
        return jsonify({'message': 'Model name is required'}), 400

    # Get the model name from the form data
    model_name = request.form['modelName']
    uploads_folder = 'uploads'  # Assuming uploads folder is located in the root directory
    # Create a folder to store the MIDI files for this model inside the UPLOAD_FOLDER
    model_folder = os.path.join('models', secure_filename(model_name))
    os.makedirs(model_folder, exist_ok=True)

    # Check if MIDI files are included in the request
    if 'midiFiles' not in request.files:
        return jsonify({'message': 'No MIDI files uploaded'}), 400

    # Iterate through each MIDI file and save it to the model folder
    midi_files = request.files.getlist('midiFiles')
    for midi_file in midi_files:
        filename = secure_filename(midi_file.filename)
        midi_file.save(os.path.join(uploads_folder, filename))

    # Perform data preparation and model training
    result = prepare_data_and_save(model_folder, uploads_folder)
    clear_upload_folder(uploads_folder)
   
 
    if result["code"]==False:
        return jsonify({'message': result["msg"]}), 400
    train_model(model_folder)

    # Return a success message with the model name
    return jsonify({'message': f'Model "{model_name}" trained successfully'}), 200


@app.route('/generate_music', methods=['POST'])
@jwt_required()
def handle_generate_music():
    if request.is_json:
        data = request.get_json()
        current_user = get_jwt_identity()
        print(f"{current_user['username']} in generate music")
        if data:
            # Check if all required fields are present
            required_fields = ['model_folder', 'duration_seconds', 'temperature', 'tempo','instrument_name']
            if all(field in data for field in required_fields):
                model_folder = data['model_folder']
                duration_seconds = data['duration_seconds']
                temperature = data['temperature']
                tempo = data['tempo']
                instrument_name=data['instrument_name']
                model_folder=f'models/{model_folder}'
                midi_data = generate_music(model_folder,current_user['username'], duration_seconds, temperature, tempo,instrument_name, save_file=False)
                response = send_file(midi_data, as_attachment=True)  
                threading.Thread(target=delete_file_after_delay, args=(midi_data,)).start()
                return response
            else:
                abort(400, 'Missing required fields in JSON data. Required fields: model_folder, duration_seconds, temperature, tempo')
        else:
            abort(400, 'Empty JSON data. Send JSON data with required fields: model_folder, duration_seconds, temperature, tempo')
    else:
        # Return instructions on how to send JSON data
        abort(400, 'Invalid JSON data. Send JSON data with required fields: model_folder, duration_seconds, temperature, tempo')

@app.route('/generate_multi_music', methods=['POST'])
@jwt_required()
def handle_generate_multi_music():
    if request.is_json:
        data = request.get_json()
        current_user = get_jwt_identity()
        print(f"{current_user} in generate multi music")
        if data:
            # Check if all required fields are present
            required_fields = ['model_folder', 'duration_seconds', 'temperature', 'tempo', 'instrument_names']
            if all(field in data for field in required_fields):
                model_folder = data['model_folder']
                duration_seconds = data['duration_seconds']
                temperature = data['temperature']
                tempo = data['tempo']
                instrument_names = data['instrument_names']
                model_folder = f'models/{model_folder}'
                midi_data = generate_multi_music(model_folder, current_user['username'], duration_seconds, temperature, tempo, instrument_names, save_file=False)
                response = send_file(midi_data, as_attachment=True)  
                threading.Thread(target=delete_file_after_delay, args=(midi_data,)).start()
                return response
            else:
                abort(400, 'Missing required fields in JSON data. Required fields: model_folder, duration_seconds, temperature, tempo, instrument_names')
        else:
            abort(400, 'Empty JSON data. Send JSON data with required fields: model_folder, duration_seconds, temperature, tempo, instrument_names')
    else:
        # Return instructions on how to send JSON data
        abort(400, 'Invalid JSON data. Send JSON data with required fields: model_folder, duration_seconds, temperature, tempo, instrument_names')

@app.route('/get_available_model_folders', methods=['GET'])
def get_available_model_folders():
    model_folders = []
    for folder in os.listdir('models'):
        if os.path.isdir(os.path.join('models', folder)):
            model_folders.append(folder)
    return jsonify({'model_folders': model_folders})

@app.route('/convert', methods=['POST'])
@jwt_required()
def convert_midi():
    if 'file' not in request.files or 'instrument' not in request.form:
        return 'File and instrument are required.', 400
    current_user = get_jwt_identity()
    print(f"{current_user['username']} in convert midi")
    midi_file = request.files['file']
    instrument_name = request.form['instrument']
    midi_file_path = os.path.join('temp', f"{current_user['username']}.mid")
    midi_file.save(midi_file_path)
    file=convert_instrument(midi_file_path,current_user['username'],instrument_name,save_file=False)
    response = send_file(file, as_attachment=True)
    threading.Thread(target=delete_file_after_delay, args=(file,)).start()
    return response


@app.route('/admin/models/delete/<string:model_name>', methods=['DELETE'])
@jwt_required()
@admin_required
def delete_model(model_name):
 # Assuming 'models' is the folder where your models are stored
    model_path = os.path.join('models', model_name)
    if os.path.exists(model_path) and os.path.isdir(model_path):
        shutil.rmtree(model_path)  # Delete the model folder
        return jsonify({'message': f'Model "{model_name}" deleted successfully'}), 200
    else:
        return jsonify({'message': f'Model "{model_name}" not found'}), 404

def clear_upload_folder(folder_path):
    # Clear all files in the specified folder
    for filename in os.listdir(folder_path):
        file_path = os.path.join(folder_path, filename)
        try:
            if os.path.isfile(file_path):
                os.unlink(file_path)
            elif os.path.isdir(file_path):
                shutil.rmtree(file_path)
        except Exception as e:
            print(f"Failed to delete {file_path}: {e}")

@app.route('/feedback', methods=['POST'])
@jwt_required()
def receive_feedback():
    try:
        # Get the feedback message from the request JSON and sanitize it
        feedback_message = request.json.get('message')
        if feedback_message is None or not isinstance(feedback_message, str):
            raise ValueError('Feedback message is missing or invalid')
        # Sanitize the feedback message to remove any HTML tags or dangerous content
        sanitized_message = bleach.clean(feedback_message, tags=[], attributes={})
        current_user = get_jwt_identity()
        print(f"{current_user['username']} in feedback")
        feedback = Feedback(message=sanitized_message, username=current_user['username'])
        db.session.add(feedback)
        db.session.commit()
        response = {'message': 'Feedback received and stored successfully'}
        return jsonify(response), 200
    except ValueError as ve:
        error_message = str(ve)
        print(f"ValueError receiving feedback: {error_message}")
        response = {'error': error_message}
        return jsonify(response), 400  # Bad Request due to invalid input
    except Exception as e:
        error_message = str(e)
        print(f"Error receiving feedback: {error_message}")
        response = {'error': error_message}
        return jsonify(response), 500  # Internal Server Error

@app.route('/admin/feedback', methods=['GET'])
@jwt_required()
@admin_required
def list_feedback():
    feedback_list = Feedback.query.all()
    feedback_data = [{'id': feedback.id, 'message': feedback.message, 'user_id': feedback.username,
                      'timestamp': feedback.timestamp.strftime('%Y-%m-%d %H:%M:%S'), 'read': feedback.read}
                     for feedback in feedback_list]
    return jsonify({'feedback': feedback_data})


@app.route('/admin/feedback/<int:feedback_id>', methods=['DELETE'])
@jwt_required()
@admin_required
def delete_feedback(feedback_id):
    feedback = db.session.get(Feedback, feedback_id)
    if not feedback:
        return jsonify({'error': 'Feedback not found'}), 404

    db.session.delete(feedback)
    db.session.commit()
    return jsonify({'message': 'Feedback deleted successfully'})


@app.route('/admin/feedback/<int:feedback_id>/markasread', methods=['PUT'])
@jwt_required()
@admin_required
def mark_feedback_as_read(feedback_id):
    feedback = db.session.get(Feedback, feedback_id)
    if not feedback:
        return jsonify({'error': 'Feedback not found'}), 404

    feedback.read = True
    db.session.commit()
    return jsonify({'message': 'Feedback marked as read'})


@app.errorhandler(404)
def page_not_found(error):
    return render_template('404.html'), 404


if __name__ == '__main__':
    with app.app_context():
     db.create_all()
     print("pikachoo")
    app.run(debug=True, port=5000, host='0.0.0.0')