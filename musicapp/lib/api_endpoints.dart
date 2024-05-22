// api_endpoints.dart

// ignore_for_file: constant_identifier_names

// Define the base URL for the API.
// const String BASE_URL = 'http://192.168.168.241:5000';
// const String BASE_URL = 'http://10.0.2.2:5000';
const String BASE_URL = 'https://brave-ocelot-properly.ngrok-free.app';

// Define the API endpoints.

const String CONVERT_INSTRUMENT_ENDPOINT = '$BASE_URL/convert';
const String FEEDBACK_ENDPOINT = '$BASE_URL/feedback';
const String GENERATE_MULTIPLE_MUSIC_ENDPOINT =
    '$BASE_URL/generate_multi_music';
const String GENERATE_MUSIC_ENDPOINT = '$BASE_URL/generate_music';
const String GET_AVAILABLE_MODEL_FOLDERS_ENDPOINT =
    '$BASE_URL/get_available_model_folders';
const String LOGIN_ENDPOINT = '$BASE_URL/login';
const String REFRESH_ENDPOINT = '$BASE_URL/refresh';
const String REGISTER_ENDPOINT = '$BASE_URL/register';
const String FORGOT_PASSWORD_ENDPOINT = '$BASE_URL/forgot_password';
const String RESET_PASSWORD_ENDPOINT = '$BASE_URL/reset_password';
const String CHANGE_PASSWORD_ENDPOINT = '$BASE_URL/change_password';

// Export the API endpoints.
